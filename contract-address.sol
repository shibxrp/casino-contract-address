// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./Token.sol";

contract Casino is Ownable{

    event RouletteGame (
        uint NumberWin,
        bool result,
        uint tokensEarned
    );

    ERC20 private token;
    address public tokenAddress;

    function precioTokens(uint256 _numTokens) public pure returns (uint256){
        return _numTokens * (0.001 ether);
    }

    function tokenBalance(address _of) public view returns (uint256){
        return token.balanceOf(_of);
    }
    constructor(){
        token =  new ERC20("i like cat and dog", "SHIBXRP");
        tokenAddress = address(token);
        token.mint(1000000);
    }

    function balanceEthersSC() public view returns (uint256){
        return address(this).balance / 10**18;
    }

    function getAdress() public view returns (address){
        return address(token);

    }

     function compraTokens(uint256 _numTokens) public payable{
        require(msg.value >= precioTokens(_numTokens), "Buy less tokens or pay with more ethers");
        if  (token.balanceOf(address(this)) < _numTokens){
            token.mint(_numTokens*100000);
        }
        payable(msg.sender).transfer(msg.value - precioTokens(_numTokens));
        token.transfer(address(this), msg.sender, _numTokens);
    }

    function devolverTokens(uint _numTokens) public payable {
        require(_numTokens > 0, "You need to return a number of tokens greater than 0");
        require(_numTokens <= token.balanceOf(msg.sender), "You don't have the tokens you want to return");
        token.transfer(msg.sender, address(this), _numTokens);
        payable(msg.sender).transfer(precioTokens(_numTokens)); 
    }

    struct Bet {
        uint tokensBet;
        uint tokensEarned;
        string game;
    }

    struct RouleteResult {
        uint NumberWin;
        bool result;
        uint tokensEarned;
    }

    mapping(address => Bet []) historialApuestas;

    function retirarEth(uint _numEther) public payable onlyOwner {
        require(_numEther > 0, "You need to return a number of tokens greater than 0");
        require(_numEther <= balanceEthersSC(), "You don't have the tokens you want to return");
        payable(owner()).transfer(_numEther);
    }

    function tuHistorial(address _propietario) public view returns(Bet [] memory){
        return historialApuestas[_propietario];
    }

    function jugarRuleta(uint _start, uint _end, uint _tokensBet) public{
        require(_tokensBet <= token.balanceOf(msg.sender));
        require(_tokensBet > 0);
        uint random = uint(uint(keccak256(abi.encodePacked(block.timestamp))) % 14);
        uint tokensEarned = 0;
        bool win = false;
        token.transfer(msg.sender, address(this), _tokensBet);
        if ((random <= _end) && (random >= _start)) {
            win = true;
            if (random == 0) {
                tokensEarned = _tokensBet*14;
            } else {
                tokensEarned = _tokensBet * 2;
            }
            if  (token.balanceOf(address(this)) < tokensEarned){
            token.mint(tokensEarned*100000);
            }
            token.transfer( address(this), msg.sender, tokensEarned);
        }
            addHistorial("Roulete", _tokensBet, tokensEarned, msg.sender);
            emit RouletteGame(random, win, tokensEarned);
    }

    function addHistorial(string memory _game, uint _tokensBet,  uint _tokenEarned, address caller) internal{
        Bet memory apuesta = Bet(_tokensBet, _tokenEarned, _game);
        historialApuestas[caller].push(apuesta);
    }

    }



