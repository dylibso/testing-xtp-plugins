import { Test } from "@dylibso/xtp-test";

// expected output format from the plugin call:
// {"api":0,"cli":0,"webapp":1,"postgres":0}
interface SourceStats {
  api: number;
  cli: number;
  webapp: number;
  postgres: number;
}

export function test() {
  const mockInput = Test.mockInputString();
  Test.group("Verify KV store integration", () => {
    for (let i = 0; i < 4; i++) {
      const output = Test.callString("handleLogEvent", mockInput);
      const stats: SourceStats = JSON.parse(output);

      Test.assertEqual(
        `webapp source increments to ${i + 1} based on iteration`,
        i + 1,
        stats.webapp,
      );
    }
  });
}
