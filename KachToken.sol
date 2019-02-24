pragma solidity ^0.5.2;

import "./ERC20.sol";
import "./Owned.sol";
import "./Crowdsale.sol";

contract KachToken is Crowdsale {
    string constant public symbol = "KHT";
    string constant public name = "KachToken";
    int constant public decimals = 18;

    address private _contractOwnerAddress;
    address private _contractAdminAddress;
    address private _contractPortalAddress;


    address private _seedInvestorAddress;
    address private _advisorAddress;
    address private _fundKeeperAddress;
    address private _teamAddress;
    address private _reservedAddress;
    address private _founderAddress;

    address[] private _privateInvestorAddresses;
    address[] private _whitelistInvestorAddresses;
    address[] private _notInWhitelistInvestorAddresses;

    uint256 private _ethPrice = 600;


    uint256 private _ICOTokensAmount = 300000000;
    // uint256 private _teamTokensAmount = 80000000;

    uint256 private _founderTokensAmount = 50000000;
    uint256 private _teamTokensAmount = 30000000;

    uint256 private _advisorTokensAmount = 50000000;
    uint256 private _earlyInvestorsTokensAmount = 20000000;
    uint256 private _reservedTokensAmount = 50000000;

    uint128 private _tokensPerEth = 3000;
    uint private _icoStartTime;
    bool private _icoStarted;

    // Projected sales (Soft Caps)
    uint private _privateSaleSoftCap = 6000000;
    uint private _preSaleSoftCap = 5000000;
    uint private _icoSoftCap = 10000000;

    bool private _tokenTransferEnabled = true;
    bool private _contractActivated;

    bool private seedInvestorTokensAllocated = false;
    bool private foundersTokensAllocated = false;
    bool private advisorTokensAllocated = false;

    uint private _totalTokensAmount = 500000000;

    modifier onlyContractActivated() {
        require(_contractActivated == true);
        _;
    }

    modifier onlyTokenTransferEnabled() {
        require(_tokenTransferEnabled == true);
        _;
    }

    function checkContractBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Construction function
    constructor() Crowdsale() public payable {
        _contractOwnerAddress = msg.sender;
        _mint(_contractOwnerAddress, _totalTokensAmount);
    }

    // Payable function to distribute token
    function() external payable onlyContractActivated onlyTokenTransferEnabled  {
        uint weiAmount = msg.value;
        _issueToken(msg.sender, weiAmount);
    }

    function activateEverything() public {
        _tokenTransferEnabled = true;
        _contractActivated = true;
        _isPrivateSaleNow = true;
        _isPreSaleNow = true;
        _icoStarted = true;
    }

    // Get current state of sales campaign
    function getCurrentState() public pure returns (bool) {
        return true;
    }

    // To track invested amount of Ether of investors not competed KYC
    function _trackdownInvestedEther() private view returns (uint256) {
        uint256 _totalBalance = 0;
        for (uint256 i = 0; i < othersAddresses.length; i++) {
            _totalBalance = _totalBalance.add(others[othersAddresses[i]]);
        }
        return _totalBalance;
    }

    // Payable to revoke token
    function revokeToken() public payable onlyOwnerAdmin {
        for (uint i = 0; i < othersAddresses.length; i++) {
            balance[othersAddresses[i]] = 0;
        }
    }

    // To activate contract
    function activateContract() public onlyOwner {
        _contractActivated = true;
    }

    // To deactivate contract
    function deactivateContract() public onlyOwner {
        _contractActivated = false;
    }

    // To enable transferring of token
    function enableTokenTransfer() public onlyOwner{
        _tokenTransferEnabled = true;
    }

    // To change the ETH wallet
    function changeFundKeeper(address _newFundKeeperAddress) public onlyOwner {
        _fundKeeperAddress = _newFundKeeperAddress;
    }

    // To change admin address
    function changeAdminAddress(address _newAdminAddress) public onlyOwner {
        changeAdmin(_newAdminAddress);
        _contractAdminAddress = _newAdminAddress;
    }

    // To change portal address
    function changePortalAddress(address _newPortalAddress) public onlyOwner {
        changePortal(_newPortalAddress);
        _contractPortalAddress = _newPortalAddress;
    }

    // To change founder address
    function changeFounderAddress(address _newFounderAddress) public onlyOwner {
        _founderAddress = _newFounderAddress;
    }

    // To change team address
    function changeTeamAddress(address _newTeamAddress) public onlyOwner {
        _teamAddress = _newTeamAddress;
    }

    // To change reserved address
    function changeReservedAddress(address _newReservedAddress) public onlyOwner {
        _reservedAddress = _newReservedAddress;
    }

    // To allocate tokens to founder
    function allocateTokenForFounder() public onlyOwnerAdmin {
        require(now <= (_icoStartTime + 12 minutes));
        require(_teamAddress != address(0));
        _approveAndTransfer(_founderAddress, _founderTokensAmount);
    }

    // To allocate tokens to team
    function allocateTokenForTeam() public onlyOwnerAdmin {
        require(now <= (_icoStartTime + 12 minutes));
        require(_teamAddress != address(0));
        _approveAndTransfer(_teamAddress, _teamTokensAmount);
    }

    // To move all tokens remaining after ICO to external address
    function moveAllAvailableToken(address _newAddress) public onlyOwnerAdmin {
        require(_newAddress != address(0));
        uint remainingTokens = _totalTokensAmount.sub(balanceOf(_contractOwnerAddress));
        _approveAndTransfer(_newAddress, remainingTokens);
    }

    // To allocate reserved token to external address
    function allocateReservedToken() public onlyOwnerAdmin {
        require(_reservedAddress != address(0));
        _approveAndTransfer(_reservedAddress, _reservedTokensAmount);
    }
}
