// curve_checks.h - elliptic curve unit tests
//
//    These constants were generated from the Mina c-reference-signer

#pragma once

#include "crypto.h"

#define THROW(x) fprintf(stderr, "\n!! FAILED %s() at %s:%d !!\n\n", \
                         __FUNCTION__, __FILE__, __LINE__); \
                 return false;

#define EPOCHS 5

// Test scalars
static const Scalar S[5][2] = {
    {
        { 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, },
        { 0x15e789b5c213f2a4, 0x3f529d13f93f3c41, 0xd2543e425ecf2414, 0x3fac61733b4de912, },
    },
    {
        { 0x50b5ec5a60ddc229, 0x42fe744d4cc75e2c, 0x18edf4d0dc389cdf, 0x2538b8bb7d9b4f5f, },
        { 0xa57d55f98868293b, 0x7c801d22c1a45a42, 0x980e39a6b18cf97b, 0x16d7b2d4672d4b10, },
    },
    {
        { 0x0d3e44d76cb73b46, 0x12e178d31ad61de7, 0x7db1bc636d9ad238, 0x3fc6b711aa4a1fab, },
        { 0x5900f79758db403d, 0xd24ecae9c0cbee08, 0x0c5955d1190bbed5, 0x24fdaa02e2a26b06, },
    },
    {
        { 0x4dcc61570bf0b56a, 0xff75263a48fcfd74, 0x59c3dd208df2c20f, 0x3a69cdf4bca0d0b3, },
        { 0x09dbb238f5d36cd2, 0x6d70d3eef0dfaa7a, 0x72fa59b2efae9a4b, 0x1ac97f027d690a5d, },
    },
    {
        { 0x3327efd3f45f5685, 0x679a53fb263e608c, 0x856d5423c9b3b05a, 0x0bf8543515fdf896, },
        { 0xaae8848a9ec725d0, 0xba85ab82a785198e, 0xedd1b5c391b9038b, 0x2d0f9e2e08237981, },
    },
};

// Test curve points
static const Affine A[5][3] = {
    {
        {
            { 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,  },
            { 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,  },
        },
        {
            { 0xd54b82d77c6c897d, 0x341849985612cbfa, 0x3bbb1b3192d6a550, 0x159eda31e611c24c,  },
            { 0x1575e23de5c5e9ce, 0xc078a0b274ada00c, 0xfd84ff6103a107ee, 0x16a9a30a7157569f,  },
        },
        {
            { 0xb9a14146ed39c44e, 0x17aa4419bdd55b6d, 0x55729f57939d5c12, 0x1ae7f09b8f1a4945,  },
            { 0x12517e29766677fb, 0x3c61428e61f8d94f, 0x36745eec01931a67, 0x06de5932dabfdb72,  },
        },
    },
    {
        {
            { 0x45d62f535ded5b98, 0xd3dfb2db07ef4502, 0x7a613e3bbe4272e0, 0x1eff2648f0e01726,  },
            { 0x4d36d0f5954eca83, 0x05e88e22a88c1466, 0x67a0de5d4feb1998, 0x124e81009f45ce2d,  },
        },
        {
            { 0xdf578bd49c679ea1, 0xf784dbd80ef2ea06, 0x919a6421fd632a11, 0x2708dea778dddfd8,  },
            { 0x6e8b4353ae676b86, 0x4bf088e52bff5c84, 0xb98bb691ce1edd96, 0x0417b14095ea2b2a,  },
        },
        {
            { 0x446b85bcc6ad689b, 0xe219ecc9f30294c3, 0x1b0a96306e3f5f26, 0x2b93579f4d355692,  },
            { 0xc5885124d0f36a94, 0x190fb89cc49e20ab, 0xf8316144f8882b6f, 0x2220a07f479465e7,  },
        },
    },
    {
        {
            { 0xc812f574a0e4e7cb, 0x5de57084c31f2d5a, 0x4daec9d740c31cf2, 0x24ca918d8d26ca6a,  },
            { 0x473c24c5ecfe4afd, 0x0ebc242458a71c30, 0x69a738855307bf11, 0x11b8ec28da46deef,  },
        },
        {
            { 0xaebfe43d3ae5b825, 0xd260817025fab5ba, 0x4b0a09b388907ead, 0x041a96ed752fc784,  },
            { 0xa472eb8887d0fb52, 0x1a7951ff27e9bd6f, 0x3e01d2b51cdf0b14, 0x0d2db9688992afeb,  },
        },
        {
            { 0x74d97ee183bf837d, 0xde37ca4bfc67588c, 0xe29417fb517ce7b6, 0x292e9a18c2a14ce0,  },
            { 0x1620c95bdbc45995, 0x8a3cd05cb0840dc7, 0xf0e0dba874c902e8, 0x1bd02ad10d3ad858,  },
        },
    },
    {
        {
            { 0xbd3c7224c5038313, 0x9786eb7e009341b7, 0x343c69d2d1e29e88, 0x324ebaa7006d73f9,  },
            { 0xac28e895d9e4ae14, 0x98444f7bb83580cc, 0x6e937b98cb4cf9b7, 0x3d6d348d771d862a,  },
        },
        {
            { 0x4723ec9e4e2bf2d9, 0xc315d6c516e89b1b, 0x0bb28b2201114f47, 0x1c208470fa6cd8ff,  },
            { 0xa37ca87f0e32c76c, 0xb5a7b6a3cda16e4b, 0x14ec13825d90193e, 0x06e35deead4f4f93,  },
        },
        {
            { 0xb7932b70cf5893ab, 0x122781eda3734d7e, 0xff8603ca682d3d2c, 0x02511828b168e67b,  },
            { 0x73533ca8dce433b5, 0xb80e0af34d975c62, 0x1c1793207b619353, 0x1e8875d2ff0a09de,  },
        },
    },
    {
        {
            { 0x8d57efd80b21f331, 0x74cc3095ad5fb9b3, 0xfd0c4338920c5858, 0x218289d958136234,  },
            { 0x9a637f71740c686c, 0x35dd02e3e198f0d5, 0x6c09eb2ed7b58fe8, 0x357a194b5153c303,  },
        },
        {
            { 0x8493e588bf1f674f, 0x6e54ea0a53b1d6e1, 0x30da04fd68279073, 0x25e0e092ed2f1481,  },
            { 0x4a103757eff0c5ef, 0x498b743089d1c1bc, 0x8df00ce0a2013703, 0x1bfa02e567da14b8,  },
        },
        {
            { 0x8cd3a7affc05c278, 0x687c4fed1cf67a65, 0x1211804562da8293, 0x1cdde0811965640c,  },
            { 0xe2f4780415b494b0, 0x2a386b8154e79752, 0x11bb096cdfb15b70, 0x1f6f1440202a602d,  },
        },
    },
};

// Target outputs
static const Affine T[5][5] = {
    {
        {
            { 0xd54b82d77c6c897d, 0x341849985612cbfa, 0x3bbb1b3192d6a550, 0x159eda31e611c24c,  },
            { 0x1575e23de5c5e9ce, 0xc078a0b274ada00c, 0xfd84ff6103a107ee, 0x16a9a30a7157569f,  },
        },
        {
            { 0xd54b82d77c6c897d, 0x341849985612cbfa, 0x3bbb1b3192d6a550, 0x159eda31e611c24c,  },
            { 0x1575e23de5c5e9ce, 0xc078a0b274ada00c, 0xfd84ff6103a107ee, 0x16a9a30a7157569f,  },
        },
        {
            { 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,  },
            { 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,  },
        },
        {
            { 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,  },
            { 0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,  },
        },
        {
            { 0x17fe5665039dd9d8, 0xa067d4e3f0a5c113, 0x8975bac1464114d8, 0x2e450f30e874c5fd,  },
            { 0x30d4e49853db310c, 0x5766e414535ba87c, 0x49eb7508763e8969, 0x18ab4184416d63f8,  },
        },
    },
    {
        {
            { 0x7b821c78e38c0ce3, 0x7466414b286f1c38, 0x1c5e5d0a2050fdf7, 0x3822b89f85381c48,  },
            { 0x30d71d652a799250, 0xb4891c4b6b26d264, 0x6e2b2560aeaf9d04, 0x2039443a41c9681e,  },
        },
        {
            { 0x7b821c78e38c0ce3, 0x7466414b286f1c38, 0x1c5e5d0a2050fdf7, 0x3822b89f85381c48,  },
            { 0x30d71d652a799250, 0xb4891c4b6b26d264, 0x6e2b2560aeaf9d04, 0x2039443a41c9681e,  },
        },
        {
            { 0x16ff4fa201c63f85, 0xc915d905e42e5448, 0x4eeeffab69c63b92, 0x32274ea0917bb0dc,  },
            { 0x3f18f437232602e5, 0x83d5ecf3e9deaf55, 0x960e271f940ad52c, 0x02d3077e6399fa61,  },
        },
        {
            { 0x45d62f535ded5b98, 0xd3dfb2db07ef4502, 0x7a613e3bbe4272e0, 0x1eff2648f0e01726,  },
            { 0x4bf65ff76ab1357e, 0x1c5e0ad960c0e4b5, 0x985f21a2b014e668, 0x2db17eff60ba31d2,  },
        },
        {
            { 0x3a703c45f0b5553b, 0xe94848343da925bc, 0x46db21f5817527d0, 0x22ccc295b054104c,  },
            { 0x65ef9279382486db, 0xad4418226bcb277a, 0x436c2e8d7d39b0d3, 0x2861c57051be39aa,  },
        },
    },
    {
        {
            { 0x6d900452536bb91a, 0x649a9ede28de03f6, 0xdc180e25a36be304, 0x001ce41669e95693,  },
            { 0x106c81af9b5137c3, 0x9caf06658d4f3562, 0x26cc89a8774d2ba8, 0x22f57bcfbfa7c549,  },
        },
        {
            { 0x6d900452536bb91a, 0x649a9ede28de03f6, 0xdc180e25a36be304, 0x001ce41669e95693,  },
            { 0x106c81af9b5137c3, 0x9caf06658d4f3562, 0x26cc89a8774d2ba8, 0x22f57bcfbfa7c549,  },
        },
        {
            { 0x1efcd5dfcbefa091, 0xaee1beba1cabb18d, 0xa8657202797289b3, 0x1a78658067e8b103,  },
            { 0x49026374209daf11, 0x987b2eb5c94f7ac6, 0x9607c5233b0e37c5, 0x2707853e701ab896,  },
        },
        {
            { 0xc812f574a0e4e7cb, 0x5de57084c31f2d5a, 0x4daec9d740c31cf2, 0x24ca918d8d26ca6a,  },
            { 0x51f10c271301b504, 0x138a74d7b0a5dceb, 0x9658c77aacf840ef, 0x2e4713d725b92110,  },
        },
        {
            { 0x45549ed29eaa495c, 0xcd02eaffa813ad6f, 0xabf4268c3bcdbae8, 0x0312088abe9964ea,  },
            { 0x3a733b6c7ef61ef4, 0x6e66caac5c5240e4, 0xdca49c5b8700d8c2, 0x17db5777a6c58b1f,  },
        },
    },
    {
        {
            { 0x3ae3c795a7ef0ba2, 0xfc06cc93531e98a3, 0xa8f3fd4e0a968cc0, 0x14894d1d6a6ac89c,  },
            { 0x4b31567dea417c7c, 0x6aebb61e17072a23, 0x72cf920cd0a740bc, 0x1209d90e61c2a2cb,  },
        },
        {
            { 0x3ae3c795a7ef0ba2, 0xfc06cc93531e98a3, 0xa8f3fd4e0a968cc0, 0x14894d1d6a6ac89c,  },
            { 0x4b31567dea417c7c, 0x6aebb61e17072a23, 0x72cf920cd0a740bc, 0x1209d90e61c2a2cb,  },
        },
        {
            { 0x612b7f4424ef11cc, 0x6d4297bd7337eb05, 0xe938a855d7c6faf1, 0x35237fa4bd9fda33,  },
            { 0xcb86447e92872c3c, 0x3e0bb19308831d98, 0x753de4ac552e7b35, 0x1797240b3e9a2fc7,  },
        },
        {
            { 0xbd3c7224c5038313, 0x9786eb7e009341b7, 0x343c69d2d1e29e88, 0x324ebaa7006d73f9,  },
            { 0xed044857261b51ed, 0x8a0249805117784e, 0x916c846734b30648, 0x0292cb7288e279d5,  },
        },
        {
            { 0x76cbd3255b0ded46, 0xa82ff017807e964f, 0x9b7b221d4b941e70, 0x3ed0e18191055574,  },
            { 0x14792345f35217c7, 0x9f933fcbc78d8568, 0x06024e8bd24718e8, 0x2f0fe6ae192d19ef,  },
        },
    },
    {
        {
            { 0x1e6829ea7a179f7e, 0xf51bc198bb3b56df, 0x75b6f6f2375e8a74, 0x2e739b942b75d8d4,  },
            { 0xcbcf3082bf41ace8, 0x666d46bf8897f8f8, 0x2a37f165128854e1, 0x005920a9e00b25aa,  },
        },
        {
            { 0x1e6829ea7a179f7e, 0xf51bc198bb3b56df, 0x75b6f6f2375e8a74, 0x2e739b942b75d8d4,  },
            { 0xcbcf3082bf41ace8, 0x666d46bf8897f8f8, 0x2a37f165128854e1, 0x005920a9e00b25aa,  },
        },
        {
            { 0x7b8e3e5aca509d23, 0x8fd347253c926a1f, 0x3f81f0c03762dc79, 0x12a40061dbf8048b,  },
            { 0xbfa9821f82284391, 0x216bdfc14f7563cc, 0x2ac57b01a7168d42, 0x1656d21bc59d1761,  },
        },
        {
            { 0x8d57efd80b21f331, 0x74cc3095ad5fb9b3, 0xfd0c4338920c5858, 0x218289d958136234,  },
            { 0xfec9b17b8bf39795, 0xec69961827b40845, 0x93f614d1284a7017, 0x0a85e6b4aeac3cfc,  },
        },
        {
            { 0xd860468ab97e6ebb, 0x4d7c12f858135aee, 0xa28eecf03136abc2, 0x2156b24bca78dce3,  },
            { 0x1b7e299806bf41a3, 0x8f41bbd472f56063, 0x652c1802ef58fe07, 0x3e14f1600b1d4da3,  },
        },
    },
};

bool curve_checks(void);
