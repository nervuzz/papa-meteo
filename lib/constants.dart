import 'package:tuple/tuple.dart';

const String APP_TITLE = 'Papa Meteo';

const Map<String, Tuple2<int, int>> LIST_OF_CITIES = {
  // (Row, Col) taken from http://meteo.icm.edu.pl
  'Białystok': Tuple2(379, 285),
  'Bydgoszcz': Tuple2(381, 199),
  'Gdańsk': Tuple2(346, 210),
  'Gorzów Wielkopolski': Tuple2(390, 152),
  'Katowice': Tuple2(461, 215),
  'Kielce': Tuple2(443, 244),
  'Kraków': Tuple2(466, 232),
  'Lublin': Tuple2(432, 277),
  'Łódź': Tuple2(418, 223),
  'Nawojowa': Tuple2(479, 247),
  'Olsztyn': Tuple2(363, 240),
  'Opole': Tuple2(449, 196),
  'Poznań': Tuple2(400, 180),
  'Rzeszów': Tuple2(465, 269),
  'Szczecin': Tuple2(370, 142),
  'Toruń': Tuple2(383, 209),
  'Warszawa': Tuple2(406, 250),
  'Wrocław': Tuple2(436, 181),
  'Zielona Góra': Tuple2(412, 155),
};
