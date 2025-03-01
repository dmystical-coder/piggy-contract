// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./Piggy.sol";

contract PiggyFactory {
    address[] public deployedPiggyBanks;
    address public constant developerAddress =
        0x486844DA9dF862BeEB09b9585f36283a98324fd0;
    mapping(address => mapping(string => address)) public piggies;

    event PiggyBankDeployed(
        address contractAddress,
        address indexed user,
        string purpose
    );

    function deployNewPiggyBank(
        uint _withdrawalDate,
        string memory _savingPurpose,
        bytes32 salt
    ) public returns (address) {
        address newPiggyBank = _deployContract(
            msg.sender,
            _savingPurpose,
            developerAddress,
            _withdrawalDate,
            salt
        );
        deployedPiggyBanks.push(newPiggyBank);
        piggies[msg.sender][_savingPurpose] = newPiggyBank;
        emit PiggyBankDeployed(newPiggyBank, msg.sender, _savingPurpose);
        return newPiggyBank;
    }

    function _deployContract(
        address _owner,
        string memory _savingPurpose,
        address _developerAddress,
        uint _withdrawalDate,
        bytes32 salt
    ) internal returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(Piggy).creationCode,
            abi.encode(
                _owner,
                _savingPurpose,
                _developerAddress,
                _withdrawalDate
            )
        );

        address contractAddress;
        assembly {
            contractAddress := create2(
                0,
                add(bytecode, 0x20),
                mload(bytecode),
                salt
            )
            if iszero(extcodesize(contractAddress)) {
                revert(0, 0)
            }
        }
        return contractAddress;
    }

    function getDeployedPiggyBanks() public view returns (address[] memory) {
        return deployedPiggyBanks;
    }

    function computeAddress(
        address _owner,
        string memory _savingPurpose,
        address _developerAddress,
        uint _withdrawalDate,
        bytes32 salt
    ) public view returns (address) {
        bytes memory bytecode = abi.encodePacked(
            type(Piggy).creationCode,
            abi.encode(
                _owner,
                _savingPurpose,
                _developerAddress,
                _withdrawalDate
            )
        );
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                salt,
                keccak256(bytecode)
            )
        );
        return address(uint160(uint(hash)));
    }

    function getPiggyAddress(
        address _user,
        string memory _purpose
    ) public view returns (address) {
        return piggies[_user][_purpose];
    }
}
