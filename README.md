# SafariFind

Long-press the **Share** button in Safari to open **Find on Page**.

Originally made by [P2KDev](https://github.com/p2kdev), who later deleted the repo, leaving only the compiled 1.1.2 `.deb`. This is an independent rewrite based on that binary, fixed to work on iOS 17.

- iOS 15 – 17, roothide (default) and rootless
- Prebuilt packages: [`packages/`](packages)

## Build

```bash
make package FINALPACKAGE=1                                  # roothide
make package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless    # rootless
```

## License

[MIT](LICENSE)
