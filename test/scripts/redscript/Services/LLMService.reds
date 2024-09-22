module Awesome.Services

import Codeware.*
import Awesome.Data.*

public class LLMService extends ScriptableService {

  private let m_tokens: array<LLMToken>;

  private cb func OnLoad() {
    FTLog("<llm-service (load) />");
  }

  private cb func OnReload() {
    FTLog("<llm-service (reload) />");
  }

}
