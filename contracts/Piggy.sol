// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error UnsupportedToken();
error InvalidAmount();
error NotAllowedToSpend(address spender, uint amount);
error InsufficientBalance(uint balance);

contract Piggy {
    string public savingPurpose;
    bool public isActive;
    uint8 public constant penaltyFee = 15;
    address public developerAddress;
    address public owner;
    uint public withdrawalDate;

    mapping(string => address) supportedTokenAddresses;
    mapping(address => mapping(string => uint)) public savedTokenBalances;

    constructor(
        address _owner,
        string memory _savingPurpose,
        uint _withdrawalDate,
        address _developerAddress
    ) {
        owner = _owner;
        savingPurpose = _savingPurpose;
        withdrawalDate = _withdrawalDate;
        developerAddress = _developerAddress;
        isActive = true;

        supportedTokenAddresses[
            "USDT"
        ] = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
        supportedTokenAddresses[
            "USDC"
        ] = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
        supportedTokenAddresses[
            "DAI"
        ] = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    modifier contractIsActive() {
        require(isActive, "Contract is no longer active");
        _;
    }

    function save(
        string memory _tokenSymbol,
        uint _amount
    ) public contractIsActive onlyOwner {
        if (!isTokenSupported(_tokenSymbol)) revert UnsupportedToken();
        address tokenAddress = supportedTokenAddresses[_tokenSymbol];
        IERC20 token = IERC20(tokenAddress);
        uint8 decimals;
        if (keccak256(abi.encodePacked(_tokenSymbol)) == keccak256(abi.encodePacked("USDT"))) {
            decimals = 6;
        } else if (keccak256(abi.encodePacked(_tokenSymbol)) == keccak256(abi.encodePacked("USDC"))) {
            decimals = 6;
        } else if (keccak256(abi.encodePacked(_tokenSymbol)) == keccak256(abi.encodePacked("DAI"))) {
            decimals = 18;
        } else {
            revert UnsupportedToken();
        }

        if (_amount == 0) revert InvalidAmount();
        uint256 amount = _amount * (10 ** uint256(decimals));

        // Check allowance
        uint256 allowance = token.allowance(msg.sender, address(this));
        if (allowance < amount) {
            revert NotAllowedToSpend(msg.sender, amount);
        }
        token.transferFrom(msg.sender, address(this), amount);
        savedTokenBalances[msg.sender][_tokenSymbol] += amount;
    }

    function withdraw(
        string memory _tokenSymbol
    ) public contractIsActive onlyOwner {
        if (!isTokenSupported(_tokenSymbol)) revert UnsupportedToken();
        address tokenAddress = supportedTokenAddresses[_tokenSymbol];
        uint balance = savedTokenBalances[msg.sender][_tokenSymbol];
        if (balance == 0) revert InsufficientBalance(balance);

        IERC20 token = IERC20(tokenAddress);

        if (block.timestamp < withdrawalDate) {
            // Early withdrawal with penalty
            uint256 penaltyAmount = (balance * penaltyFee) / 100;
            uint256 netAmount = balance - penaltyAmount;

            require(
                token.transfer(developerAddress, penaltyAmount),
                "Penalty transfer failed"
            );
            require(token.transfer(msg.sender, netAmount), "Transfer failed");
        } else {
            // Withdrawal without penalty
            require(token.transfer(msg.sender, balance), "Transfer failed");
        }

        savedTokenBalances[msg.sender][_tokenSymbol] -= balance;
        isActive = false;
    }

    function isTokenSupported(
        string memory _tokenSymbol
    ) public view returns (bool) {
        return supportedTokenAddresses[_tokenSymbol] != address(0);
    }
}
