class CurrencyManager {
  static final CurrencyManager _instance = CurrencyManager._internal();
  factory CurrencyManager() => _instance;
  CurrencyManager._internal();

  String _currencySymbol = "Rs.";

  String get currencySymbol => _currencySymbol;

  void setCurrencySymbol(String symbol) {
    _currencySymbol = symbol;
  }
}

String get currentCurrencySymbol => CurrencyManager().currencySymbol;
