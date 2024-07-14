module Awesome.Data

@if(ModuleExists("RedData.Json"))
import RedData.Json.*
@if(!ModuleExists("RedData.Json"))
import Codeware.*

public struct LLMToken {

  public let content: String;
  public let size: Uint32;
  public let line: Uint32;
  public let offset: Uint32;

  @if(ModuleExists("RedData.Json"))
  public static func GetJson() -> ref<JsonObject>;

  @if(!ModuleExists("Codeware"))
  public static func GetPersistent() -> ref<IScriptable>;

}
