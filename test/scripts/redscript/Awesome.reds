module Awesome

import Awesome.Services.*

public class Awesome extends ScriptableSystem {
  private let m_llmService: ref<LLMService>;

  private cb func OnAttach() {
    this.m_llmService = null;
    LogChannel(n"Info", "<awesome (attach) />");
  }

}
