# tq-compiler (port Swift 1:1)

Port de `tq-compiler` (C# / .NET 10) para Swift, sem corrigir a semântica do original
(o projeto está incompleto e vários trechos são bugs preservados de propósito — marcados com `(sic)`).

| C# (`Src/…`)        | Swift (`Sources/…`) |
|---------------------|---------------------|
| Tqc.Diagnostics     | TqcDiagnostics      |
| Tqc.Logging         | TqcLogging          |
| Tqc.Build           | TqcBuild            |
| Tqc.Build.Toml      | TqcBuildToml (TOMLKit no lugar de Tomlyn) |
| Tqc.Syntax          | TqcSyntax           |
| Tqc.Semantics       | TqcSemantics        |
| Tqc.IR              | TqcIR               |
| Tqc.Module.Tq       | TqcModuleTq (arquivo original não compila; mantido como comentário) |
| Tqc.CLI             | TqcCLI (produto `tqc`) |
| — (BCL do .NET)     | TqcSystem (StringBuilder, BigInteger, Version, exceções, dicionário ordenado, File/Path) |

`Resources/` (`.tq`, `build.toml`, `ilverify.sh`) foi copiado sem alterações.

Uso: `swift run tqc build_toml ./Resources/build.toml`
