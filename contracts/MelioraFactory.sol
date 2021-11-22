// SPDX-License-Identifier: MIT

//** Meliora Crowfunding Contract*/
//** Author Alex Hong : Meliora Finance 2021.5 */

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "./libraries/IERC20.sol";
import "./MelioraLaunchpad.sol";
import "./MelioraInfo.sol";

contract MelioraFactory {
    using SafeMath for uint256;

    event LaunchpadCreated(bytes32 title, uint256 launchId, address creator);

    address private constant wethAddress =
        address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    MelioraInfo public immutable MELIORA;

    constructor(address _melioraInfoAddress) public {
        MELIORA = MelioraInfo(_melioraInfoAddress);
    }

    struct LaunchpadInfo {
        address tokenAddress;
        address unsoldTokensDumpAddress;
        address[] whitelistedAddresses;
        uint256 tokenPriceInWei;
        uint256 hardCapInWei;
        uint256 softCapInWei;
        uint256 maxInvestInWei;
        uint256 minInvestInWei;
        uint256 openTime;
        uint256 closeTime;
    }

    struct LaunchpadStringInfo {
        bytes32 saleTitle;
        bytes32 linkTelegram;
        bytes32 linkDiscord;
        bytes32 linkTwitter;
        bytes32 linkWebsite;
    }

    function initializeLaunchpad(
        MelioraLaunchpad _launchpad,
        uint256 _totalTokens,
        uint256 _finalTokenPriceInWei,
        LaunchpadInfo memory _info,
        LaunchpadStringInfo memory _stringInfo
    ) internal {
        _launchpad.setAddressInfo(
            msg.sender,
            _info.tokenAddress,
            _info.unsoldTokensDumpAddress
        );
        _launchpad.setGeneralInfo(
            _totalTokens,
            _finalTokenPriceInWei,
            _info.hardCapInWei,
            _info.softCapInWei,
            _info.maxInvestInWei,
            _info.minInvestInWei,
            _info.openTime,
            _info.closeTime
        );

        _launchpad.setStringInfo(
            _stringInfo.saleTitle,
            _stringInfo.linkTelegram,
            _stringInfo.linkDiscord,
            _stringInfo.linkTwitter,
            _stringInfo.linkWebsite
        );

        _launchpad.addwhitelistedAddresses(_info.whitelistedAddresses);
    }

    function createLaunchpad(
        LaunchpadInfo memory _info,
        LaunchpadStringInfo memory _stringInfo
    ) public {
        IERC20 token = IERC20(_info.tokenAddress);

        MelioraLaunchpad launchpad =
            new MelioraLaunchpad(address(this), MELIORA.owner());

        uint256 maxTokensToBeSold =
            _info.hardCapInWei.mul(1e18).div(_info.tokenPriceInWei);
        // uint256 maxEthPoolTokenAmount =
        //     _info.hardCapInWei.mul(_uniInfo.liquidityPercentageAllocation).div(
        //         100
        //     );
        // uint256 maxLiqPoolTokenAmount =
        //     maxEthPoolTokenAmount.mul(1e18).div(_uniInfo.listingPriceInWei);
        // uint256 requiredTokenAmount =
        //     maxLiqPoolTokenAmount.add(maxTokensToBeSold);
        uint256 requiredTokenAmount = 1e18;
        token.transferFrom(msg.sender, address(launchpad), requiredTokenAmount);

        initializeLaunchpad(
            launchpad,
            maxTokensToBeSold,
            _info.tokenPriceInWei,
            _info,
            _stringInfo
        );

        uint256 melioraId = MELIORA.addLaunchpadAddress(address(launchpad));

        emit LaunchpadCreated(_stringInfo.saleTitle, melioraId, msg.sender);
    }
}
