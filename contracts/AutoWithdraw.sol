// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// AutomationCompatible.sol imports the functions from both ./AutomationBase.sol and
// ./interfaces/AutomationCompatibleInterface.sol
import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IBank {
    function withdrawTokenToOwner(address, uint256) external;
}

contract AutoWithdraw is AutomationCompatibleInterface {
    address immutable tokenAddr;
    address immutable BankAddr;
    uint256 public threshold;

    constructor(address _tokenAddr, address _BankAddr, uint256 _threshold) {
        tokenAddr = _tokenAddr;
        BankAddr = _BankAddr;
        require(_threshold > 0, "invalid threshold");
        threshold = _threshold;
    }

    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory /* performData */)
    {
        upkeepNeeded = IERC20(tokenAddr).balanceOf(BankAddr) >= threshold;
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        IBank(BankAddr).withdrawTokenToOwner(tokenAddr, (IERC20(tokenAddr).balanceOf(BankAddr) - (IERC20(tokenAddr).balanceOf(BankAddr) % 2)) / 2);
    }
}
