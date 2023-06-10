class IcmApi {
  static const String apiEndpoint =
      'https://www.meteo.pl/um/metco/mgram_pict.php';
  String forecastPeriod;
  String lang;
  int row;
  int col;

  IcmApi(this.forecastPeriod, this.row, this.col, {this.lang = 'pl'});

  String build() {
    return '$apiEndpoint?ntype=0u&fdate=$forecastPeriod&row=$row&col=$col&lang=$lang';
  }
}
