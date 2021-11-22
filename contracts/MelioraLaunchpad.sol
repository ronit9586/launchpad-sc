// SPDX-License-Identifier: MIT

//** Meliora Crowfunding Contract*/
//** Author Alex Hong : Meliora Finance 2021.5 */

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "./libraries/IERC20.sol";
import "./libraries/SafeMath.sol";

contract MelioraLaunchpad {
    using SafeMath for uint256;

    address payable internal melioraFactoryAddress;
    address payable public melioraDevAddress;

    IERC20 public token;
    address payable public launchpadCreatorAddress;
    address public unsoldTokensDumpAddress;

    mapping(address => uint256) public investments;
    mapping(address => bool) public whitelistedAddresses;
    mapping(address => bool) public claimed;

    uint256 private melioraDevFeePercentage;
    uint256 private melioraMinDevFeeInWei;
    uint256 public melioraId;

    uint256 public totalInvestorsCount;
    uint256 public launchpadCreatorClaimWei;
    uint256 public launchpadCreatorClaimTime;
    uint256 public totalCollectedWei;
    uint256 public totalTokens;
    uint256 public tokensLeft;
    uint256 public tokenPriceInWei;
    uint256 public hardCapInWei;
    uint256 public softCapInWei;
    uint256 public maxInvestInWei;
    uint256 public minInvestInWei;
    uint256 public openTime;
    uint256 public closeTime;
    bool public onlyWhitelistedAddressesAllowed = true;
    bool public melioraDevFeesExempted = false;
    bool public launchpadCancelled = false;

    bytes32 public saleTitle;
    bytes32 public linkTelegram;
    bytes32 public linkTwitter;
    bytes32 public linkDiscord;
    bytes32 public linkWebsite;

    constructor(address _melioraFactoryAddress, address _melioraDevAddress)
        public
    {
        require(_melioraFactoryAddress != address(0));
        require(_melioraDevAddress != address(0));

        melioraFactoryAddress = payable(_melioraFactoryAddress);
        melioraDevAddress = payable(_melioraDevAddress);
    }

    modifier onlyMelioraDev() {
        require(
            melioraFactoryAddress == msg.sender ||
                melioraDevAddress == msg.sender
        );
        _;
    }

    modifier onlyMelioraFactory() {
        require(melioraFactoryAddress == msg.sender);
        _;
    }

    modifier onlyLaunchpadCreatorOrmelioraFactory() {
        require(
            launchpadCreatorAddress == msg.sender ||
                melioraFactoryAddress == msg.sender,
            "Not launchpad creator or factory"
        );
        _;
    }

    modifier onlyLaunchpadCreator() {
        require(launchpadCreatorAddress == msg.sender, "Not launchpad creator");
        _;
    }

    modifier whitelistedAddressOnly() {
        require(
            !onlyWhitelistedAddressesAllowed ||
                whitelistedAddresses[msg.sender],
            "Address not whitelisted"
        );
        _;
    }

    modifier launchpadIsNotCancelled() {
        require(!launchpadCancelled, "Cancelled");
        _;
    }

    modifier investorOnly() {
        require(investments[msg.sender] > 0, "Not an investor");
        _;
    }

    modifier notYetClaimedOrRefunded() {
        require(!claimed[msg.sender], "Already claimed or refunded");
        _;
    }

    function setAddressInfo(
        address _launchpadCreator,
        address _tokenAddress,
        address _unsoldTokensDumpAddress
    ) external onlyMelioraFactory {
        require(_launchpadCreator != address(0));
        require(_tokenAddress != address(0));
        require(_unsoldTokensDumpAddress != address(0));

        launchpadCreatorAddress = payable(_launchpadCreator);
        token = IERC20(_tokenAddress);
        unsoldTokensDumpAddress = _unsoldTokensDumpAddress;
    }

    function setGeneralInfo(
        uint256 _totalTokens,
        uint256 _tokenPriceInWei,
        uint256 _hardCapInWei,
        uint256 _softCapInWei,
        uint256 _maxInvestInWei,
        uint256 _minInvestInWei,
        uint256 _openTime,
        uint256 _closeTime
    ) external onlyMelioraFactory {
        require(_totalTokens > 0);
        require(_tokenPriceInWei > 0);
        require(_openTime > 0);
        require(_closeTime > 0);
        require(_hardCapInWei > 0);

        require(_hardCapInWei <= _totalTokens.mul(_tokenPriceInWei));
        require(_softCapInWei <= _hardCapInWei);
        require(_minInvestInWei <= _maxInvestInWei);
        require(_openTime < _closeTime);

        totalTokens = _totalTokens;
        tokensLeft = _totalTokens;
        tokenPriceInWei = _tokenPriceInWei;
        hardCapInWei = _hardCapInWei;
        softCapInWei = _softCapInWei;
        maxInvestInWei = _maxInvestInWei;
        minInvestInWei = _minInvestInWei;
        openTime = _openTime;
        closeTime = _closeTime;
    }

    function setStringInfo(
        bytes32 _saleTitle,
        bytes32 _linkTelegram,
        bytes32 _linkDiscord,
        bytes32 _linkTwitter,
        bytes32 _linkWebsite
    ) external onlyLaunchpadCreatorOrmelioraFactory {
        saleTitle = _saleTitle;
        linkTelegram = _linkTelegram;
        linkDiscord = _linkDiscord;
        linkTwitter = _linkTwitter;
        linkWebsite = _linkWebsite;
    }

    function setMelioraInfo(
        uint256 _melioraDevFeePercentage,
        uint256 _melioraMinDevFeeInWei,
        uint256 _melioraId
    ) external onlyMelioraDev {
        melioraDevFeePercentage = _melioraDevFeePercentage;
        melioraMinDevFeeInWei = _melioraMinDevFeeInWei;
        melioraId = _melioraId;
    }

    function setmelioraDevFeesExempted(bool _melioraDevFeesExempted)
        external
        onlyMelioraDev
    {
        melioraDevFeesExempted = _melioraDevFeesExempted;
    }

    function setOnlyWhitelistedAddressesAllowed(
        bool _onlyWhitelistedAddressesAllowed
    ) external onlyLaunchpadCreatorOrmelioraFactory {
        onlyWhitelistedAddressesAllowed = _onlyWhitelistedAddressesAllowed;
    }

    function addwhitelistedAddresses(address[] calldata _whitelistedAddresses)
        external
        onlyLaunchpadCreatorOrmelioraFactory
    {
        onlyWhitelistedAddressesAllowed = _whitelistedAddresses.length > 0;
        for (uint256 i = 0; i < _whitelistedAddresses.length; i++) {
            whitelistedAddresses[_whitelistedAddresses[i]] = true;
        }
    }

    function getTokenAmount(uint256 _weiAmount)
        internal
        view
        returns (uint256)
    {
        return _weiAmount.mul(1e18).div(tokenPriceInWei);
    }

    function invest()
        public
        payable
        whitelistedAddressOnly
        launchpadIsNotCancelled
    {
        require(block.timestamp >= openTime, "Not yet opened");
        require(block.timestamp < closeTime, "Closed");
        require(totalCollectedWei < hardCapInWei, "Hard cap reached");
        require(tokensLeft > 0);
        require(msg.value <= tokensLeft.mul(tokenPriceInWei));
        uint256 totalInvestmentInWei = investments[msg.sender].add(msg.value);
        require(
            totalInvestmentInWei >= minInvestInWei ||
                totalCollectedWei >= hardCapInWei.sub(1 ether),
            "Min investment not reached"
        );
        require(
            maxInvestInWei == 0 || totalInvestmentInWei <= maxInvestInWei,
            "Max investment reached"
        );

        if (investments[msg.sender] == 0) {
            totalInvestorsCount = totalInvestorsCount.add(1);
        }

        totalCollectedWei = totalCollectedWei.add(msg.value);
        investments[msg.sender] = totalInvestmentInWei;
        tokensLeft = tokensLeft.sub(getTokenAmount(msg.value));
    }

    receive() external payable {
        invest();
    }

    function addLiquidityAndLockLPTokens() external launchpadIsNotCancelled {
        require(totalCollectedWei > 0);
        require(
            !onlyWhitelistedAddressesAllowed ||
                whitelistedAddresses[msg.sender] ||
                msg.sender == launchpadCreatorAddress,
            "Not whitelisted or not launchpad creator"
        );

        if (totalCollectedWei >= hardCapInWei.sub(1 ether)) {
            require(
                msg.sender == launchpadCreatorAddress,
                "Not launchpad creator"
            );
        } else {
            revert("Liquidity cannot be added yet");
        }

        uint256 finalTotalCollectedWei = totalCollectedWei;
        uint256 melioraDevFeeInWei;
        if (!melioraDevFeesExempted) {
            uint256 pctDevFee =
                finalTotalCollectedWei.mul(melioraDevFeePercentage).div(100);
            melioraDevFeeInWei = pctDevFee > melioraMinDevFeeInWei ||
                melioraMinDevFeeInWei >= finalTotalCollectedWei
                ? pctDevFee
                : melioraMinDevFeeInWei;
        }
        if (melioraDevFeeInWei > 0) {
            finalTotalCollectedWei = finalTotalCollectedWei.sub(
                melioraDevFeeInWei
            );
            melioraDevAddress.transfer(melioraDevFeeInWei);
        }

        uint256 unsoldTokensAmount =
            token.balanceOf(address(this)).sub(
                getTokenAmount(totalCollectedWei)
            );
        if (unsoldTokensAmount > 0) {
            token.transfer(unsoldTokensDumpAddress, unsoldTokensAmount);
        }

        launchpadCreatorClaimWei = address(this).balance.mul(1e18).div(
            totalInvestorsCount.mul(1e18)
        );
        launchpadCreatorClaimTime = block.timestamp + 1 days;
    }

    function claimTokens()
        external
        whitelistedAddressOnly
        launchpadIsNotCancelled
        investorOnly
        notYetClaimedOrRefunded
    {
        claimed[msg.sender] = true; // make sure this goes first before transfer to prevent reentrancy
        token.transfer(msg.sender, getTokenAmount(investments[msg.sender]));

        uint256 balance = address(this).balance;
        if (balance > 0) {
            uint256 funds =
                launchpadCreatorClaimWei > balance
                    ? balance
                    : launchpadCreatorClaimWei;
            launchpadCreatorAddress.transfer(funds);
        }
    }

    function getRefund()
        external
        whitelistedAddressOnly
        investorOnly
        notYetClaimedOrRefunded
    {
        if (!launchpadCancelled) {
            require(block.timestamp >= openTime, "Not yet opened");
            require(block.timestamp >= closeTime, "Not yet closed");
            require(softCapInWei > 0, "No soft cap");
            require(totalCollectedWei < softCapInWei, "Soft cap reached");
        }

        claimed[msg.sender] = true; // make sure this goes first before transfer to prevent reentrancy
        uint256 investment = investments[msg.sender];
        uint256 launchpadBalance = address(this).balance;
        require(launchpadBalance > 0);

        if (investment > launchpadBalance) {
            investment = launchpadBalance;
        }

        if (investment > 0) {
            msg.sender.transfer(investment);
        }
    }

    function cancelAndTransferTokensTolaunchpadCreator() external {
        if (
            launchpadCreatorAddress != msg.sender &&
            melioraDevAddress != msg.sender
        ) {
            revert();
        }

        require(!launchpadCancelled);
        launchpadCancelled = true;

        uint256 balance = token.balanceOf(address(this));
        if (balance > 0) {
            token.transfer(launchpadCreatorAddress, balance);
        }
    }
}
