// ignore_for_file: library_private_types_in_public_api

import 'package:calculator/theme/colors.dart';
import 'package:calculator/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String display = '0';
  String currentOperation = '';
  String? operator;
  double firstOperand = 0;
  double secondOperand = 0;
  bool lightMode = true;
  bool isResultCalculated = false;

  void launchYoutubeVideo() async {
    final Uri url = Uri.parse('https://www.youtube.com/watch?v=JmEyUOLDGFA');
    launchUrl(url, mode: LaunchMode.externalApplication);
  }

  String formatResult(double result) {
    if (result == result.roundToDouble()) {
      return result.toStringAsFixed(0);
    } else {
      return result.toStringAsFixed(4);
    }
  }

  void buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        display = '0';
        currentOperation = '';
        firstOperand = 0;
        secondOperand = 0;
        operator = null;
        isResultCalculated = false;
      } else if (buttonText == '+' ||
          buttonText == '-' ||
          buttonText == 'x' ||
          buttonText == '/') {
        if (operator != null && display.isEmpty) {
          return;
        }

        if (isResultCalculated) {
          currentOperation = '$display $buttonText ';
          operator = buttonText;
          display = '';
          isResultCalculated = false;
        } else {
          if (currentOperation.isNotEmpty) {
            secondOperand = double.parse(display);
            double result;
            if (operator == '+') {
              result = firstOperand + secondOperand;
            } else if (operator == '-') {
              result = firstOperand - secondOperand;
            } else if (operator == 'x') {
              result = firstOperand * secondOperand;
            } else if (operator == '/') {
              if (secondOperand == 0) {
                display = "0";
                currentOperation = '';
                operator = null;
                return;
              }
              result = firstOperand / secondOperand;
            } else {
              result = 0;
            }
            display = '';
            currentOperation = '${formatResult(result)} $buttonText ';
            firstOperand = result;
            operator = buttonText;
            isResultCalculated = false;
          } else {
            currentOperation += '$display $buttonText ';
            operator = buttonText;
            firstOperand = double.parse(display);
            display = '';
            isResultCalculated = false;
          }
        }
      } else if (buttonText == '=') {
        if (operator != null && display.isNotEmpty) {
          secondOperand = double.parse(display);
          double result;
          if (operator == '+') {
            result = firstOperand + secondOperand;
          } else if (operator == '-') {
            result = firstOperand - secondOperand;
          } else if (operator == 'x') {
            result = firstOperand * secondOperand;
          } else if (operator == '/') {
            if (secondOperand == 0) {
              display = "0";
              currentOperation = '';
              operator = null;
              return;
            }
            result = firstOperand / secondOperand;
          } else {
            result = 0;
          }
          display = formatResult(result);
          currentOperation += '${formatResult(secondOperand)} =';
          firstOperand = result;
          operator = null;
          secondOperand = 0;
          isResultCalculated = true;

          if (display == '666') {
            launchYoutubeVideo();
          }
        }
      } else if (buttonText == 'DEL') {
        if (display.isNotEmpty) {
          display = display.substring(0, display.length - 1);
          if (display.isEmpty) {
            display = '0';
          }
        }
      } else if (buttonText == '+/-') {
        if (display != '0') {
          if (display.startsWith('-')) {
            display = display.substring(1);
          } else {
            display = '-$display';
          }
          firstOperand = double.parse(display);
        }
      } else if (buttonText == '%' && display.isNotEmpty) {
        double value = double.parse(display);
        display = formatResult(value / 100);
      } else {
        if (display == '0' || isResultCalculated) {
          display = buttonText;
          isResultCalculated = false;
        } else {
          display += buttonText;
        }
      }
    });
  }

  Color buttonTextColor(String buttonText) {
    if (buttonText == '/' ||
        buttonText == 'x' ||
        buttonText == '-' ||
        buttonText == '+' ||
        buttonText == '=') {
      return AppColors.operatorColor;
    } else if (buttonText == 'DEL' ||
        buttonText == '+/-' ||
        buttonText == '%') {
      return AppColors.extraColor;
    } else {
      if (lightMode) {
        return Colors.black;
      } else {
        return Colors.white;
      }
    }
  }

  TextSpan buildOperationText(String operation) {
    final matches = RegExp(r' ([\+\-x\/]) ').allMatches(operation);
    List<TextSpan> spans = [];
    int lastIndex = 0;

    for (final match in matches) {
      // Dodaj tekst przed operatorem
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: operation.substring(lastIndex, match.start),
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }

      // Dodaj operator z wybranym kolorem
      spans.add(
        TextSpan(
          text: match.group(0),
          style: const TextStyle(
            fontSize: 24,
            color: Colors.red,
          ),
        ),
      );

      // Zaktualizuj `lastIndex` na koniec obecnego operatora
      lastIndex = match.end;
    }

    // Dodaj pozostały tekst po ostatnim operatorze
    if (lastIndex < operation.length) {
      spans.add(
        TextSpan(
          text: operation.substring(lastIndex),
          style: TextStyle(
            fontSize: 24,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            setState(() {
              lightMode = !lightMode;
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: lightMode ? Colors.black : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.nightlight_round,
                    color: lightMode ? Colors.grey.shade400 : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RichText(
                    textAlign: TextAlign.right,
                    text: buildOperationText(currentOperation),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double fontSize = 60;
                      final textSpan = TextSpan(
                        text: display,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                      final textPainter = TextPainter(
                        text: textSpan,
                        maxLines: 1,
                        textDirection: TextDirection.ltr,
                      );
                      textPainter.layout();
                      while (textPainter.width > constraints.maxWidth &&
                          fontSize > 0) {
                        fontSize--;
                        textPainter.text = TextSpan(
                          text: display,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                        textPainter.layout();
                      }
                      return Text(
                        textAlign: TextAlign.right,
                        display,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      calculatorButton('DEL'),
                      calculatorButton('+/-'),
                      calculatorButton('%'),
                      calculatorButton('/'),
                    ],
                  ),
                  Row(
                    children: [
                      calculatorButton('7'),
                      calculatorButton('8'),
                      calculatorButton('9'),
                      calculatorButton('x'),
                    ],
                  ),
                  Row(
                    children: [
                      calculatorButton('4'),
                      calculatorButton('5'),
                      calculatorButton('6'),
                      calculatorButton('-'),
                    ],
                  ),
                  Row(
                    children: [
                      calculatorButton('1'),
                      calculatorButton('2'),
                      calculatorButton('3'),
                      calculatorButton('+'),
                    ],
                  ),
                  Row(
                    children: [
                      calculatorButton('C'),
                      calculatorButton('0'),
                      calculatorButton('.'),
                      calculatorButton('='),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget calculatorButton(String buttonText) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () => buttonPressed(buttonText),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              border: Border.all(
                  color: lightMode ? Colors.white : Colors.grey.shade600),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                buttonText,
                style:
                    TextStyle(fontSize: 24, color: buttonTextColor(buttonText)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
