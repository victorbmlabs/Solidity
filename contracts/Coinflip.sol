pragma solidity ^0.8.24;
import "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Coinflip is IEntropyConsumer {
    constructor(address _entropy, address _provider) {
        entropy = IEntropy(_entropy);
        provider = _provider;
    }

    event WagerCreated(address creator, uint64 wagerValue, uint256 gameId);
    event WagerCommenced(uint64 id); // When a game has two players and will start
    event FlipResult(uint64 id, address winner, bool heads)


    using Counters for Counters.Counter;
    Counters.Counter public gameId;

    mapping(uint256 => Wager) public wagerMap;
    mapping(bytes32 => uint256) public requestIdGameId;

    enum RESULT { HEADS, TAILS, NONE }
    RESULT public flipResult;

    enum STATE { OPEN, CLOSED, PROCESSING, DELETED }
    STATE public state;

    struct Wager {
        address payable player1; // Creator
        address payable player2; 
        RESULT player1Result;
        RESULT player2Result;
        STATE state;
        uint256 prize;
        address payable winner;
    }

    Wager[] betHistory;
    Wager bet;
    uint64 public maxBetAmount = 10000000000000000000; // 10 Ether in wei's
    uint8 public minBetAmount =  2000000000000000; // 0.002 Ether in wei's 

    modifier validState(STATE state) {
        require(state != STATE.NOT_SET, "Cannot have an unset game state")
    }

    function createWager(SATE state) public payable validState(state) {
        require(msg.value => minBetAmount, "Bet value is below the minimal betting value.")

        uint64 _id = gameId.current();
        gameId.increment();

        Wager memory _wager = Wager({
            id: _id,
            player1: payable(msg.sender),
            player2: payable(address(0)),
            player1State: state,
            player2State: STATE.NOT_sET,
            prize: msg.value,
            winner: payable(address(0))
        });

        wagerMap[_id] = _wager;
        emit WagerCreated(msg.sender, msg.value, _id);
    }

    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }
}