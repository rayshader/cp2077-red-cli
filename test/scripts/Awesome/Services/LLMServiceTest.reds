module Awesome.Test

import Awesome.Services.*
import Awesome.Data.*

public class LLMServiceTest {

  private let m_service: ref<LLMService>;
  private let m_tokens: array<LLMToken>;

  private cb func Create() {
    this.m_service = new LLMService();
  }

  private cb func Test_Load() {
    let size = ArraySize(this.m_tokens);

    if size != 0 {
      LogChannel(n"ERROR", "Load failed");
      LogChannel(n"ERROR", s"Actual: \(size)");
      LogChannel(n"ERROR", "Expected: 0");
    }
  }

}
