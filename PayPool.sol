// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract PayPool is ReentrancyGuard {
    struct DepositRecord {
        address depositor;
        uint256 amount;
        uint256 timestamp;
        DepositStatus status;
    }

    enum DepositStatus {
        Pending,
        Approved,
        Rejected
    }

    DepositRecord[] public depositHistory;
    uint public totalBalance;
    address public owner;

    event Deposit(address indexed depositer, uint256 amount);
    event DepositStatusChanged(uint256 index, DepositStatus status);

    modifier isOwner() {
        require(msg.sender == owner, "Not owner!");
        _;
    }

    constructor() payable {
        owner = msg.sender;
    }

    function deposit() external payable {
        DepositRecord memory record = DepositRecord({
            depositor: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp,
            status: DepositStatus.Pending
        });
        depositHistory.push(record);
        emit Deposit(msg.sender, msg.value);
    }

    function approveDeposit(uint256 index) external isOwner {
        require(index < depositHistory.length, "Index out of bounds");
        depositHistory[index].status = DepositStatus.Approved;
        emit DepositStatusChanged(index, DepositStatus.Approved);
    }

    function rejectDeposit(uint256 index) external isOwner {
        require(index < depositHistory.length, "Index out of bounds");
        depositHistory[index].status = DepositStatus.Rejected;
        emit DepositStatusChanged(index, DepositStatus.Rejected);
    }

    function getDepositHistory() public view returns (DepositRecord[] memory) {
        return depositHistory;
    }
}
