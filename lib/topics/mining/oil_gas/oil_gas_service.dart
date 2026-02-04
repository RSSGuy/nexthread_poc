import '../../../core/models.dart';
import '../../../core/market_data_provider.dart';

class OilGasService {
  /// Fetches the market pulse for Oil & Gas.
  /// Currently utilizes the Multi-Benchmark logic (Mining = Energy + Metals)
  /// defined in [SectorBenchmarks].
  Future<MarketFact> getFacts() async {
    return await MarketDataProvider().getSectorBenchmarks(Naics.mining);
  }
}