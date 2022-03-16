import 'package:flutter/material.dart';

class _GameBoardWinningMark {
  final double angle;
  final Offset offset;
  final double? widthAddition;

  _GameBoardWinningMark(
      {required this.angle, required this.offset, this.widthAddition});
}

class Game extends StatefulWidget {
  const Game({Key? key}) : super(key: key);

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  List<List<int>> _gameBoard = [
    [-4, -4, -4],
    [-4, -4, -4],
    [-4, -4, -4],
  ];

  final Map<int, List<_GameBoardWinningMark>> _winningLineMap = {
    0: [
      _GameBoardWinningMark(offset: const Offset(0, -40), angle: 0),
      _GameBoardWinningMark(offset: const Offset(0, 25), angle: 0),
      _GameBoardWinningMark(offset: const Offset(0, 95), angle: 0)
    ],
    1: [
      _GameBoardWinningMark(
          offset: const Offset(25, 75), angle: 7.855, widthAddition: -60),
      _GameBoardWinningMark(
          offset: const Offset(25, 0), angle: 7.855, widthAddition: -60),
      _GameBoardWinningMark(
          offset: const Offset(25, -75), angle: 7.855, widthAddition: -60),
    ],
    2: [
      _GameBoardWinningMark(offset: const Offset(20, 15), angle: 95),
      _GameBoardWinningMark(offset: const Offset(-15, 20), angle: 55.8)
    ]
  };

  int _winningCordIndex = -1;
  set winningCordIndex(int idx) {
    if (_winningCordIndex == -1) {
      setState(() {
        _winningCordIndex = idx;
      });
    }
  }

  int _winningConfigIndex = -1;
  set winningConfigIndex(int idx) {
    if (_winningConfigIndex == -1) {
      setState(() {
        _winningConfigIndex = idx;
      });
    }
  }

  bool firstPlayerTurn = true;
  bool isGameEnded = false;
  int gameWonBy = -1;

  _reset() {
    setState(() {
      _gameBoard = [
        [-4, -4, -4],
        [-4, -4, -4],
        [-4, -4, -4],
      ];
      isGameEnded = false;
      gameWonBy = -1;
      _winningCordIndex = -1;
      _winningConfigIndex = -1;
    });
  }

  bool _winningCondition(int value) {
    bool isPlayer1Won = value == 0;
    bool isPlayer2Won = value == _gameBoard.length;
    bool isAnyoneWon = isPlayer1Won || isPlayer2Won;
    if (isAnyoneWon) {
      setState(() {
        gameWonBy = isPlayer1Won ? 1 : 2;
      });
    }
    return isAnyoneWon;
  }

  _evaluateIsGameEnded() {
    List<bool> checks = [];

    // Horizontal check
    var rowsCheck = _gameBoard.map((row) => row.reduce((v1, v2) => v1 + v2));
    checks.add(rowsCheck.where(_winningCondition).isNotEmpty);
    winningCordIndex = rowsCheck.toList().indexWhere(_winningCondition);
    winningConfigIndex = _winningCordIndex >= 0 ? 0 : -1;

    // Vertical check
    checks.add((() {
      List<int> colsSums = [0, 0, 0];
      for (var row in _gameBoard) {
        for (var col in row.asMap().entries) {
          colsSums[col.key] += col.value;
        }
      }
      winningCordIndex = colsSums.indexWhere(_winningCondition);
      winningConfigIndex = _winningCordIndex >= 0 ? 1 : -1;
      return colsSums.where(_winningCondition).isNotEmpty;
    })());

    diagonalCheck({bool isReverse = false}) => _winningCondition(
        (isReverse ? _gameBoard.reversed.toList() : _gameBoard)
            .asMap()
            .entries
            .map((row) => row.value[row.key])
            .reduce((v1, v2) => v1 + v2));

    // LTR diagonal check
    var diagonal0to2Check = diagonalCheck();
    checks.add(diagonal0to2Check);
    winningCordIndex = diagonal0to2Check ? 0 : -1;
    winningConfigIndex = diagonal0to2Check ? 2 : -1;

    // RTL diagonal check
    var diagonal2to0Check = diagonalCheck(isReverse: true);
    checks.add(diagonal2to0Check);
    winningCordIndex = diagonal2to0Check ? 1 : -1;
    winningConfigIndex = diagonal2to0Check ? 2 : -1;

    // Draw check
    var flattenBoardSum =
        _gameBoard.expand((row) => row).reduce((v1, v2) => v1 + v2);
    if (checks.where((check) => check).isNotEmpty || flattenBoardSum > 0) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    double cardMargin = 100;
    var cardWidth = 200;
    var hasWinningLineConfigs =
        _winningConfigIndex >= 0 && _winningCordIndex >= 0;
    _GameBoardWinningMark? markConfigs =
        _winningLineMap[_winningConfigIndex]?[_winningCordIndex];

    return Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Card(
                    clipBehavior: Clip.antiAlias,
                    margin: EdgeInsets.only(
                        left: cardMargin,
                        right: cardMargin,
                        top: cardMargin,
                        bottom: cardMargin / 2),
                    elevation: 10,
                    child: Transform.scale(
                      scale: 1.010,
                      child: Column(
                        children: _gameBoard
                            .asMap()
                            .entries
                            .map((row) => Expanded(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: row.value
                                        .asMap()
                                        .entries
                                        .map((col) => Expanded(
                                              child: InkWell(
                                                onTap: _gameBoard[row.key]
                                                            [col.key] >=
                                                        0
                                                    ? null
                                                    : () {
                                                        setState(() {
                                                          _gameBoard[row.key]
                                                                  [col.key] =
                                                              firstPlayerTurn
                                                                  ? 1
                                                                  : 0;
                                                          firstPlayerTurn =
                                                              !firstPlayerTurn;
                                                          isGameEnded =
                                                              _evaluateIsGameEnded();
                                                        });
                                                      },
                                                child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.black,
                                                            width: 1)),
                                                    child: col.value < 0
                                                        ? const SizedBox
                                                            .shrink()
                                                        : Text(
                                                            "${col.value}",
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        30),
                                                          )),
                                              ),
                                            ))
                                        .toList(),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                  Center(
                    child: Transform.rotate(
                      angle: markConfigs?.angle ?? 0,
                      child: Transform.translate(
                        offset: markConfigs?.offset ?? const Offset(0, 0),
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 250),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.green,
                            ),
                            height: 10,
                            width: (isGameEnded && hasWinningLineConfigs)
                                ? cardWidth + (markConfigs?.widthAddition ?? 0)
                                : 0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (isGameEnded)
                    Align(
                        alignment: Alignment.topCenter,
                        child: Text("Game Won! Won By Player $gameWonBy"))
                ],
              ),
            ),
            ElevatedButton(onPressed: _reset, child: const Text('Reset'))
          ],
        ),
      ),
    );
  }
}
