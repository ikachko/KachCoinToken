pragma solidity ^0.5.2;
import "./Owned.sol";
import "./SafeMath.sol";
import "./ERC20.sol";

contract Actors is Owned {
    using SafeMath for uint256;

    mapping (address => bool) internal isPrivateInvestor;
    mapping (address => bool) internal isInWhiteList;
    mapping (address => uint256) internal others;


     // To add new addresses to whitelist
    function addToWhitelist(address[] memory _whiteListAddresses) public onlyOwnerAdminPortal {
        for (uint256 i = 0; i < _whiteListAddresses.length; i++) {
            if (_whiteListAddresses[i] != address(0)) {
                isInWhiteList[_whiteListAddresses[i]] = true;
            }
        }
    }

    // To remove addresses from whitelist
    function removeFromWhitelist(address[] memory _whiteListAddresses) public onlyOwnerAdminPortal {
        for (uint256 i = 0; i < _whiteListAddresses.length; i++) {
            if (_whiteListAddresses[i] != address(0)) {
                isInWhiteList[_whiteListAddresses[i]] = false;
            }
        }
    }

    // To add new addresses to private list
    function addPrivateInvestor(address[] memory _privateInvestorAddresses) public onlyOwnerAdminPortal {
        for (uint256 i = 0; i < _privateInvestorAddresses.length; i++) {
            if (_privateInvestorAddresses[i] != address(0)) {
                isPrivateInvestor[_privateInvestorAddresses[i]] = true;
            }
        }
    }

    // To remove addreses from private list
    function removePrivateInvestor(address[] memory _privateInvestorAddresses) public onlyOwnerAdminPortal {
        for (uint256 i = 0; i < _privateInvestorAddresses.length; i++) {
            if (_privateInvestorAddresses[i] != address(0)) {
                isPrivateInvestor[_privateInvestorAddresses[i]] = false;
            }
        }
    }

    function nonVerificatedTransfer(address _investor, uint256 _weiAmount) internal onlyOwner {
        others[_investor] = others[_investor].add(_weiAmount);
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

    uint private tokenPriceInWei = 334000000000000;


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


    // Bonuses coefficients
    uint private _privateSaleBonus = 60;
    uint private _preSaleBonus = 30;
    uint private _ICOFirstPhaseBonus = 20;
    uint private _ICOSecondPhaseBonus = 10;



    uint256 _icoStartTime;

    bool _icoStarted;

    bool _isPrivateSaleNow;
    bool _isPreSaleNow;

    constructor() public onlyOwner {
        _icoCompleted = false;
        _contractOwnerAddress = msg.sender;
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
    function setPrivateSalePrice() public onlyOwnerAdmin {
        // Nope
    }

    // To set price before starting presales
    function setPreSalePrice() public onlyOwnerAdmin {
        // Nope
    }

    // To set standart price before starting ICO
    function setICOPrice() public onlyOwnerAdmin {
        // Nope
    }

    function _applyBonus(uint256 _tokenAmount, uint256 _bonus) private pure returns (uint256) {
        uint256 _resultToken = _tokenAmount +  (_tokenAmount.mul(_bonus)).div(100);
        return _resultToken;
    }

    // To distribute token to private investor
    function _issueTokenForPrivateInvestor(address _investor, uint256 _tokenAmount) private {
        uint256 _tokenAmountWithBonus = _applyBonus(_tokenAmount, _privateSaleBonus);

        _approveAndTransfer(_investor, _tokenAmountWithBonus);
    }

    // To distribute token to normal investors joined presales
    function _issueTokenForPresale(address _investor, uint256 _tokenAmount) private {
        uint256 _tokenAmountWithBonus = _applyBonus(_tokenAmount, _preSaleBonus);

        _approveAndTransfer(_investor, _tokenAmountWithBonus);
    }

    // To distribute token to normal investors joined ICO
    function _issueTokenForICO(address _investor, uint256 _tokenAmount) private {
        uint256 _tokenAmountWithBonus;

        if (isICOPhaseOne()) {
            _tokenAmountWithBonus = _applyBonus(_tokenAmount, _ICOFirstPhaseBonus);
        }
        else if (isICOPhaseTwo()) {
            _tokenAmountWithBonus = _applyBonus(_tokenAmount, _ICOSecondPhaseBonus);
        }
        else {
            _tokenAmountWithBonus = _tokenAmount;
        }
        _approveAndTransfer(_investor, _tokenAmountWithBonus);
    }

    // To distribute token to investor and transfer ETH to our wallet
    function _issueToken(address _investor, uint256 _weiAmount) private {
        uint256 _tokenAmount = _weiAmount.div(tokenPriceInWei);
        // uint256 _change = _weiAmount.mod(tokenPriceInWei);

        if (isPrivateSaleNow() && isPrivateInvestor[_investor]) {
            _issueTokenForPrivateInvestor(_investor, _tokenAmount);
        }
        else if (isPreSaleNow() && isInWhiteList[_investor]) {
            _issueTokenForPresale(_investor, _tokenAmount);
        }
        else if (isICOStarted()) {
            if (isInWhiteList[_investor]) {
                _issueTokenForICO(_investor, _tokenAmount);
            }
            else {
                nonVerificatedTransfer(_investor, _weiAmount);
                _approveAndTransfer(_investor, _tokenAmount);
            }
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

    function _approveAndTransfer(address _investor, uint256 _tokenAmount) private {
        _approve(_contractOwnerAddress, _investor, _tokenAmount);
        _transfer(_contractOwnerAddress, _investor, _tokenAmount);
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
