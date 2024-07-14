module Awesome.Services

import Codeware.*
import Awesome.Data.*

public class LLMService extends ScriptableService {

  private let m_tokens: array<LLMToken>;

  private cb func OnLoad() {
    LogChannel(n"Info", "<llm-service (load) />");
  }

  private cb func OnReload() {
    LogChannel(n"Info", "<llm-service (reload) />");
  }

}
