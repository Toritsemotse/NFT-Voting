// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// Interface for interacting with ERC721 NFT contracts
interface IERC721 {
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract NFTVoting {
    struct Proposal {
        string description;
        uint256 voteCount;
        address proposer;
    }

    // Array to store all proposals
    Proposal[] public proposals;

    // Mapping to track whether an address has voted on a particular proposal
    mapping(uint256 => mapping(address => bool)) public hasVoted;

    // Address of the NFT contract
    IERC721 public nftContract;

    // Token ID required for voting
    uint256 public votingTokenId;

    // Owner of the contract (for administrative purposes)
    address public owner;

    // Events
    event ProposalCreated(uint256 proposalId, string description, address proposer);
    event Voted(uint256 proposalId, address voter);

    // Modifier to restrict access to only the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    constructor(address _nftContract, uint256 _votingTokenId) {
        nftContract = IERC721(_nftContract);
        votingTokenId = _votingTokenId;
        owner = msg.sender;
    }

    // Function to create a new proposal
    function createProposal(string memory _description) external {
        proposals.push(Proposal({
            description: _description,
            voteCount: 0,
            proposer: msg.sender
        }));

        emit ProposalCreated(proposals.length - 1, _description, msg.sender);
    }

    // Function to vote on a proposal
    function vote(uint256 _proposalId) external {
        require(_proposalId < proposals.length, "Proposal does not exist");
        require(!hasVoted[_proposalId][msg.sender], "You have already voted on this proposal");
        require(nftContract.ownerOf(votingTokenId) == msg.sender, "You do not own the required NFT");

        // Mark the user as having voted
        hasVoted[_proposalId][msg.sender] = true;

        // Increment the vote count for the proposal
        proposals[_proposalId].voteCount++;

        emit Voted(_proposalId, msg.sender);
    }

    // Function to get the total number of proposals
    function getProposalCount() external view returns (uint256) {
        return proposals.length;
    }

    // Function to get the details of a specific proposal
    function getProposal(uint256 _proposalId) external view returns (string memory, uint256, address) {
        require(_proposalId < proposals.length, "Proposal does not exist");

        Proposal memory proposal = proposals[_proposalId];
        return (proposal.description, proposal.voteCount, proposal.proposer);
    }

    // Function to update the NFT contract or token ID (only owner can call this)
    function updateNFTContract(address _nftContract, uint256 _tokenId) external onlyOwner {
        nftContract = IERC721(_nftContract);
        votingTokenId = _tokenId;
    }
}
