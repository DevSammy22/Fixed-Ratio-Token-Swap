// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TokenABC.sol";
import "./TokenXYZ.sol";

contract TokenSwap {
    /*State variable*/
    address payable investor;
    //ratioXY is the percentage of how much TokenA is worth of TokenX
    uint256 ratioXY;
    bool isCheaperThanX;
    uint256 fees;
    TokenABC public tokenABC;
    TokenXYZ public tokenXYZ;

    constructor(address _tokenABC, address _tokenXYZ) {
        investor = payable(msg.sender);
        tokenABC = TokenABC(_tokenABC);
        tokenXYZ = TokenXYZ(_tokenXYZ);
        tokenABC.approve(address(this), tokenABC.totalSupply());
        tokenXYZ.approve(address(this), tokenABC.totalSupply());
    }

    modifier onlyInvestor() {
        payable(msg.sender) == investor;
        _;
    }

    function setRatio(uint256 _ratio) public onlyInvestor {
        ratioXY = _ratio;
    }

    function getRatio() public view onlyInvestor returns (uint256) {
        return ratioXY;
    }

    function setFees(uint256 _fees) public onlyInvestor {
        fees = _fees;
    }

    function getFees() public view onlyInvestor returns (uint256) {
        return fees;
    }

    // accepts amount of TokenABC and exchenge it for TokenXYZ, vice versa with function swapTKX
    // transfer tokensABC from sender to smart contract after the user has approved the smart contract to
    // withdraw amount TKA from his account, this is a better solution since it is more open and gives the
    // control to the user over what calls are transfered instead of inspecting the smart contract
    // approve the caller to transfer one time from the smart contract address to his address
    // transfer the exchanged TokenXYZ to the sender

    function swapIT(uint256 amountIT) public returns (uint256) {
        //check if amount given is not 0
        // check if current contract has the necessary amout of Tokens to exchange
        require(amountIT > 0, "amountIT must be greater than zero");
        require(
            tokenABC.balanceOf(msg.sender) >= amountIT,
            "sender doesn't have enough Tokens"
        );

        uint256 exchangeX = amountIT / ratioXY;
        uint256 exchangeAmount = exchangeX - ((exchangeX * fees) / 100);

        require(
            exchangeAmount > 0,
            "exchange amount must be greater than zero"
        );
        require(
            tokenABC.balanceOf(address(this)) > exchangeAmount,
            "currently the exchange doesn't have enough XYZ Tokens, please retry later"
        );
        tokenXYZ.transferFrom(msg.sender, address(this), amountIT);
        tokenABC.approve(address(msg.sender), exchangeAmount);
        tokenABC.transferFrom(
            address(this),
            address(msg.sender),
            exchangeAmount
        );

        return exchangeAmount;
    }

    //leting the Admin of the TokenSwap to buyTokens manually is preferable and better then letting the contract
    // buy automatically tokens since contracts are immutable and in case the value of some tokens beomes
    // worthless its better to not to do any exchange at all
    function buyTokensABC(uint256 amount) public payable onlyInvestor {
        tokenABC.buyTokens{value: msg.value}(amount);
    }

    function buyTokensXYZ(uint256 amount) public payable onlyInvestor {
        tokenXYZ.buyTokens{value: msg.value}(amount);
    }

    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}
