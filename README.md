# Liquid Splits

- the unofficial plugin for the [0xSplits](https://www.0xsplits.xyz/) protocol.

### Known Issues

- tokenIds.length must be safe divisor (ex. 11 tokens will crash).
- how to handle multiple tokens owned by the same wallet? increase share for individual or raise % for all?

### Credits

- [0xSplits](https://www.0xsplits.xyz/)
- [Headless Chaos](https://chaos.build/)

## Testing - Mumbai

- `_nftContractAddress`: `0x1ABDAa80b00340d98E8B80272f930346c839dF85`
- `_tokenIds`: `[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,60]`

### ThirdWeb Release

1. Visit [MERGE](https://thirdweb.com/sweetman.eth/MERGE) on Thirdweb.
1. Click "Deploy Now" button.
1. Select any network.
1. Deploy MERGE.
1. Use `purchase` to mint on your website.
