module Awesome.Services

import RedData.Json.*
import RedFileSystem.*

public class StorageService {

  private let m_storage: ref<FileSystemStorage>;

  public func Start() {
    this.m_storage = FileSystem.GetStorage("Awesome");
  }

  public func Load() {
    if !Equals(this.m_storage.Exists("config.json"), FileSystemStatus.True) {
      return;
    }
    let file = this.m_storage.GetFile("config.json");
    let json = file.ReadAsJson();

    LogChannel(n"DEBUG", s"Json: \(json.ToString("  ")");
  }

}
