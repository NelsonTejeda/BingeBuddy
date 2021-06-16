
class ProviderModel{
  String _logoPath;
  int _providerID;
  String _providerName;

  ProviderModel(String logoPath, int providerID, String providerName){
    this._logoPath = "https://image.tmdb.org/t/p/w500" + logoPath;
    this._providerID = providerID;
    this._providerName = providerName;
  }

  String get providerName => _providerName;

  int get providerID => _providerID;

  String get logoPath => _logoPath;
}