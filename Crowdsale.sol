pragma solidity ^0.5.2;
import "./Owned.sol";
import "./SafeMath.sol";
import "./ERC20.sol";

contract Actors is Owned {
    using SafeMath for uint256;

    mapping (address => bool) internal isPrivateInvestor;
    mapping (address => bool) internal isInWhiteList;

    mapping (address => bool) internal notVerificated;
    mapping (address => uint256) internal others;
    address[] internal othersAddresses;


     // To add new addresses to whitelist
    function addToWhitelist(address _whiteListAddress) public onlyOwnerAdminPortal {
        if (_whiteListAddress != address(0)) {
            isInWhiteList[_whiteListAddress] = true;
        }
    }

    // To remove addresses from whitelist
    function removeFromWhitelist(address _whiteListAddress) public onlyOwnerAdminPortal {
        if (_whiteListAddress != address(0)) {
            isInWhiteList[_whiteListAddress] = false;
        }
    }

    // To add new addresses to private list
    function addPrivateInvestor(address _privateInvestorAddress) public onlyOwnerAdminPortal {
        if (_privateInvestorAddress != address(0)) {
            isPrivateInvestor[_privateInvestorAddress] = true;
        }
    }

    // To remove addreses from private list
    function removePrivateInvestor(address _privateInvestorAddress) public onlyOwnerAdminPortal {
        if (_privateInvestorAddress != address(0)) {
            isPrivateInvestor[_privateInvestorAddress] = false;
        }
    }
}

contract Crowdsale is Owned, Actors, ERC20 {
    using SafeMath for uint256;

    bool private _icoCompleted;

    address private _contractOwnerAddress;
    address private _contractAdminAddress;
    address private _contractPortalAddress;

    address private _founderAddress;

    address private _fundKeeperAddress;
    address private _teamAddress;
    address private _reservedAddress;

    uint private tokenPriceInWei = 334000000000000 wei;
    uint private tokenPrivateSalePriceInWei = 217100000000000 wei;
    uint private tokenPreSalePriceInWei = 250500000000000 wei;
    uint private tokenICOPhaseOnePriceInWei = 283900000000000 wei;
    uint private tokenICOPhaseTwoPriceInWei = 300600000000000 wei;

    uint private privateSaleTokensIssued = 0;
    uint private privateSaleTokensCap = 48000000;

    uint private preSaleTokensIssued = 0;
    uint private preSaleTokensCap = 32500000;

    uint private ICOPhaseOneTokensIssued = 0;
    uint private ICOPhaseOneTokensCap = 60000000;

    uint private ICOPhaseTwoTokensIssued = 0;
    uint private ICOPhaseTwoTokensCap = 55000000;

    uint private ICOPhaseThreeTokensIssued = 0;
    uint private ICOPhaseThreeTokensCap = 50000000;

    uint private futureDonationsTokensIssued = 0;
    uint private futureDonationsTokensCap = 54000000;

    // Rounds :
    // ICO First Phase
    uint private _ICOFirstPhaseStartTime;
    uint private _ICOFirstPhaseEndTime;
    // ICO Second Phase
    uint private _ICOSecondPhaseStartTime;
    uint private _ICOSecondPhaseEndTime;
    // ICO Third Phase
    uint private _ICOThirdPhaseStartTime;
    uint private _ICOThirdPhaseEndTime;

    address private _tokenAddress;
    uint256 private _fundingGoal;

    uint256 _icoStartTime;

    bool internal _icoStarted;
    bool internal _isPrivateSaleNow;
    bool internal _isPreSaleNow;

    uint GAS_LIMIT = 4000000;

    // Total amount of ether raised
    uint private amountRaised = 0;


    function printWei() public pure returns (uint) {
        uint256 amount = 334 szabo;
        return amount;
    }

    constructor() Owned() public {
        _icoCompleted = false;
        _contractOwnerAddress = msg.sender;
        approve(_contractOwnerAddress, 500000000);
    }

    /*
    ** Contract modifiers
    */

    modifier whenIcoCompleted {
        require(_icoCompleted);
        _;
    }

    modifier notEmpty(address a) {
        require(a != address(0));
        _;
    }

    // To start ICO
    function startICO() public onlyOwnerAdmin {
        _icoStartTime = now;
        _ICOFirstPhaseStartTime = now;
        _ICOFirstPhaseEndTime = _ICOFirstPhaseStartTime + 3;

        _ICOSecondPhaseStartTime = _ICOFirstPhaseEndTime;
        _ICOSecondPhaseEndTime = _ICOSecondPhaseStartTime + 3;

        _ICOThirdPhaseStartTime = _ICOSecondPhaseEndTime;
        _ICOThirdPhaseEndTime = _ICOThirdPhaseStartTime + 3;

        _icoStarted = true;

        endPreSale();
    }

    // To end ICO
    function endICO() public onlyOwnerAdmin {
        _icoCompleted = true;
    }

    // To set price before starting private sales
    function setPrivateSalePrice(uint256 _newPriceInWei) public onlyOwnerAdmin {
        tokenPrivateSalePriceInWei = _newPriceInWei;
    }

    // To set price before starting presales
    function setPreSalePrice(uint256 _newPriceInWei) public onlyOwnerAdmin {
        tokenPreSalePriceInWei = _newPriceInWei;
    }

    // To set standart price before starting ICO
    function setICOPrice(uint256 _newPriceInWei) public onlyOwnerAdmin {
        tokenPriceInWei = _newPriceInWei;
    }

    function returnEther(address _investor, uint256 _weiAmount) public payable {
        // require(address(this).balance >= _weiAmount);
        // _investor.transfer.gas(GAS_LIMIT)(_weiAmount);
    }

    // To distribute token to private investor
    function _issueTokenForPrivateInvestor(address _investor, uint256 _weiAmount) public  {
        uint256 _tokenAmountWithBonus = _weiAmount.div(tokenPrivateSalePriceInWei);

        if (privateSaleTokensIssued + _tokenAmountWithBonus <= privateSaleTokensCap) {
            _approveAndTransfer(_investor, _tokenAmountWithBonus);
            privateSaleTokensIssued = privateSaleTokensIssued.add(_tokenAmountWithBonus);
            amountRaised = amountRaised.add(_weiAmount);
        }
        else {
            // revert();
            returnEther(_investor, _weiAmount);
        }
    }

    // To distribute token to normal investors joined presales
    function _issueTokenForPresale(address _investor, uint256 _weiAmount) private {
        uint256 _tokenAmountWithBonus = _weiAmount.div(tokenPreSalePriceInWei);
        if (preSaleTokensIssued + _tokenAmountWithBonus <= preSaleTokensCap) {
            _approveAndTransfer(_investor, _tokenAmountWithBonus);
            preSaleTokensIssued = preSaleTokensIssued.add(_tokenAmountWithBonus);
            amountRaised = amountRaised.add(_weiAmount);
        }
    }

    // To distribute token to normal investors joined ICO
    function _issueTokenForICO(address _investor, uint256 _weiAmount) private {
        uint256 _tokenAmountWithBonus;

        if (isICOPhaseOne()) {
            _tokenAmountWithBonus = _weiAmount.div(tokenICOPhaseOnePriceInWei);
            if (ICOPhaseOneTokensIssued + _tokenAmountWithBonus <= ICOPhaseOneTokensCap) {
                _approveAndTransfer(_investor, _tokenAmountWithBonus);
                ICOPhaseOneTokensIssued = ICOPhaseOneTokensIssued.add(_tokenAmountWithBonus);
                amountRaised = amountRaised.add(_weiAmount);
            }
            else {
                returnEther(_investor, _weiAmount);
            }
        }
        else if (isICOPhaseTwo()) {
            _tokenAmountWithBonus = _weiAmount.div(tokenICOPhaseTwoPriceInWei);
            if (ICOPhaseTwoTokensIssued + _tokenAmountWithBonus <= ICOPhaseTwoTokensCap) {
                _approveAndTransfer(_investor, _tokenAmountWithBonus);
                ICOPhaseTwoTokensIssued = ICOPhaseTwoTokensIssued.add(_tokenAmountWithBonus);
                amountRaised = amountRaised.add(_weiAmount);
            }
            else {
                returnEther(_investor, _weiAmount);
            }
        }
        else {
            _tokenAmountWithBonus = _weiAmount.div(tokenPriceInWei);
            if (ICOPhaseThreeTokensIssued + _tokenAmountWithBonus <= ICOPhaseThreeTokensCap) {
                _approveAndTransfer(_investor, _tokenAmountWithBonus);
                ICOPhaseThreeTokensIssued = ICOPhaseThreeTokensIssued.add(_tokenAmountWithBonus);
                amountRaised = amountRaised.add(_weiAmount);
            }
            else {
                returnEther(_investor, _weiAmount);
            }
        }
    }

    function nonVerificatedTransfer(address _investor, uint256 _weiAmount) internal {
        others[_investor] = others[_investor].add(_weiAmount);
        if (notVerificated[_investor] == false) {
            notVerificated[_investor] = true;
            othersAddresses.push(_investor);
        }
    }


    // To distribute token to investor and transfer ETH to our wallet
    function _issueToken(address _investor, uint256 _weiAmount) internal {
        // nonVerificatedTransfer(_investor, _weiAmount);
        // uint256 tokens = _weiAmount.div(tokenPriceInWei);
        // _approveAndTransfer(_investor, tokens);

        if (isPrivateSaleNow() && isPrivateInvestor[_investor]) {
            _issueTokenForPrivateInvestor(_investor, _weiAmount);
        }
        else if (isPreSaleNow() && isInWhiteList[_investor]) {
             _issueTokenForPresale(_investor, _weiAmount);
        }
        else if (isICOStarted()) {
            if (isInWhiteList[_investor]) {
                 _issueTokenForICO(_investor, _weiAmount);
            }
             else {
                 nonVerificatedTransfer(_investor, _weiAmount);
                 uint256 tokens = _weiAmount.div(tokenPriceInWei);
                 _approveAndTransfer(_investor, tokens);
            }
        }
        else {
            nonVerificatedTransfer(_investor, _weiAmount);
            uint256 tokens = _weiAmount.div(tokenPriceInWei);
            _approveAndTransfer(_investor, tokens);
        }

    }

    // To start private sales
    function startPrivateSale() public onlyOwnerAdmin {
        _isPrivateSaleNow = true;
    }

    // To start presales
    function startPreSale() public onlyOwnerAdmin {
        _isPreSaleNow = true;
    }

    // To end presales
    function endPreSale() public onlyOwnerAdmin {
        _isPreSaleNow = false;
    }

    function _approveAndTransfer(address _investor, uint256 _tokenAmount) internal returns (uint256) {
        _balances[_contractOwnerAddress] = _balances[_contractOwnerAddress].sub(_tokenAmount);
        _balances[_investor] = _balances[_investor].add(_tokenAmount);
    }

    function isPrivateSaleNow() private view returns (bool) {
        return (_isPrivateSaleNow);
    }

    function isPreSaleNow() private view returns (bool) {
        return (_isPreSaleNow);
    }

    function isICOStarted() private view returns (bool) {
        return _icoStarted;
    }

    function isICOPhaseOne() private view returns (bool) {
        return (now >= _ICOFirstPhaseStartTime && now < _ICOFirstPhaseEndTime);
    }

    function isICOPhaseTwo() private view returns (bool) {
        return (now >= _ICOSecondPhaseStartTime && now < _ICOSecondPhaseEndTime);
    }

    function isICOPhaseThree() private view returns (bool) {
        return (now >= _ICOThirdPhaseStartTime && now < _ICOThirdPhaseEndTime);
    }
}
