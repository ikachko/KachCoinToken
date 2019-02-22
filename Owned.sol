pragma solidity ^0.5.2;

contract Owned {
    address private _ownerAddress;
    address private _adminAddress;
    address private _portalAddress;

    constructor() internal {
        _ownerAddress = msg.sender;
        _adminAddress = msg.sender;
        _portalAddress = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == _ownerAddress);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == _adminAddress);
        _;
    }

    modifier onlyPortal() {
        require(msg.sender == _portalAddress);
        _;
    }

    modifier onlyOwnerAdminPortal() {
        require(
            msg.sender == _ownerAddress ||
            msg.sender == _adminAddress ||
            msg.sender == _portalAddress);
        _;
    }

    modifier onlyOwnerAdmin() {
        require(
            msg.sender == _ownerAddress ||
            msg.sender == _adminAddress );
        _;
    }

    function changeOwner(address _newOwner) public onlyOwner {
        _ownerAddress = _newOwner;
    }

    function changeAdmin(address _newAdmin) public onlyOwner {
        _adminAddress = _newAdmin;
    }

    function changePortal(address _newPortal) public onlyOwner {
        _portalAddress = _newPortal;
    }
}
