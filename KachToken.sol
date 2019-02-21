pragma solidity ^0.5.2;

import "./ERC20.sol";
import "./Owned.sol";

contract KachToken is ERC20, Owned {

    address private _contractOwnerAddress;
    address private _contractAdminAddress;
    address private _contractPortalAddress;

    address private _founderAddress;

    address private _fundKeeperAddress;
    address private _teamAddress;
    address private _reservedAddress;

    address[] private _privateInvestorAddresses;
    address[] private _whitelistInvestorAddresses;
    address[] private _notInWhitelistInvestorAddresses;

    uint256 _ethPrice = 600;

    uint256 _ICOTokensAmount = 300000000;
    uint256 _teamTokensAmount = 80000000;
    uint256 _advisorTokensAmount = 50000000;
    uint256 _earlyInvestorsTokensAmount = 20000000;
    uint256 _reservedTokensAmount = 50000000;

    // Construction function
    constructor() external {
        _contractOwner = msg.sender;
        _totalSupply = 500000000;
    }

    // Payable function to distribute token
    function() external payable {

    }

    // Get current state of sales campaign
    function getCurrentState() public {

    }

    // To distribute token to private investor
    function _issueTokenForPrivateInvestor() private {

    }

    // To distribute token to normal investors joined presales
    function _issueTokenForPresale() private {

    }

    // To distribute token to normal investors joined ICO
    function _issueTokenForICO() private {

    }

    // To track invested amount of Ether of investors not competed KYC
    function _trackdownInvestedEther() private {

    }

    // To distribute token to investor and transfer ETH to our wallet
    function _issueToken() private {

    }

    // To add new addresses to whitelist
    function addToWhitelist(address[] _whiteListAddresses) public onlyOwnerAdminPortal {

    }

    // To remove addresses from whitelist
    function removeFromWhitelist(address[] _whiteListAddresses) public onlyOwnerAdminPortal {

    }

    // To add new addresses to private list
    function addPrivateInvestor(address[] _privateInvestorAddresses) public onlyOwnerAdminPortal {

    }

    // To remove addreses from private list
    function removePrivateInvestor(address[] _privateInvestorAddresses) public onlyOwnerAdminPortal {

    }

    // To start private sales
    function startPrivateSale() public onlyOwnerAdmin {

    }

    // To start presales
    function startPreSale() public onlyOwnerAdmin {

    }

    // To end presales
    function endPreSale() public onlyOwnerAdmin {

    }

    // To start ICO
    function startICO() public onlyOwnerAdmin {

    }

    // To end ICO
    function endICO() public onlyOwnerAdmin {

    }

    // To set price before starting private sales
    function setPrivateSalePrice() public onlyOwnerAdmin {

    }

    // To set price before starting presales
    function setPreSalePrice() public onlyOwnerAdmin {

    }

    // To set standart price before starting ICO
    function setICOPrice() public onlyOwnerAdmin {

    }

    // Payable to revoke token
    function revokeToken() public payable onlyOwnerAdmin {

    }

    // To activate contract
    function activateContract() public onlyOwner {

    }

    // To deactivate contract
    function deactivateContract() public onlyOwner {

    }

    // To enable transferring of token
    function enableTokenTransfer() public onlyOwner{

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

    }

    // To allocate tokens to team
    function allocateTokenForTeam() public onlyOwnerAdmin {

    }

    // To move all tokens remaining after ICO to external address
    function moveAllAvailableToken() public onlyOwnerAdmin {

    }

    // To allocate reserved token to external address
    function allocateReservedToken() public onlyOwnerAdmin {

    }
    }

}
