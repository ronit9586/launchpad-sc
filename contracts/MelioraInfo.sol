// SPDX-License-Identifier: MIT

//** Meliora Crowfunding Contract*/
//** Author Alex Hong : Meliora Finance 2021.5 */

pragma solidity 0.6.6;
pragma experimental ABIEncoderV2;

import "./libraries/Ownable.sol";

contract MelioraInfo is Ownable {
    uint256 private devFeePercentage = 1;
    uint256 private minDevFeeInWei = 1 ether;
    address[] private launchpadAddresses;

    /**
     *
     * @dev add launchpage adress to the pool
     *
     */
    function addLaunchpadAddress(address _launchapd)
        external
        returns (uint256)
    {
        launchpadAddresses.push(_launchapd);
        return launchpadAddresses.length - 1;
    }

    /**
     *
     * @dev get launchpad count
     *
     */
    function getLaunchpadCount() external view returns (uint256) {
        return launchpadAddresses.length;
    }

    /**
     *
     * @dev get launchpad address
     *
     */
    function getLaunchpadAddress(uint256 launchId)
        external
        view
        returns (address)
    {
        return launchpadAddresses[launchId];
    }

    /**
     *
     * @dev get allocated percentage
     *
     */
    function getDevFeePercentage() external view returns (uint256) {
        return devFeePercentage;
    }

    /**
     *
     * @dev set custom fee percent
     *
     */
    function setDevFeePercentage(uint256 _devFeePercentage) external onlyOwner {
        devFeePercentage = _devFeePercentage;
    }

    /**
     *
     * @dev get minimum dev fee
     *
     */
    function getMinDevFeeInWei() external view returns (uint256) {
        return minDevFeeInWei;
    }

    /**
     *
     * @dev set minimum dev fee
     *
     */
    function setMinDevFeeInWei(uint256 _minDevFeeInWei) external onlyOwner {
        minDevFeeInWei = _minDevFeeInWei;
    }
}
