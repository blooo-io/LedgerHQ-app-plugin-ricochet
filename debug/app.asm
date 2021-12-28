
bin/app.elf:     file format elf32-littlearm


Disassembly of section .text:

c0de0000 <main>:
    libcall_params[2] = RUN_APPLICATION;
    os_lib_call((unsigned int *) &libcall_params);
}

// Weird low-level black magic. No need to edit this.
__attribute__((section(".boot"))) int main(int arg0) {
c0de0000:	b5b0      	push	{r4, r5, r7, lr}
c0de0002:	b090      	sub	sp, #64	; 0x40
c0de0004:	4604      	mov	r4, r0
    // Exit critical section
    __asm volatile("cpsie i");
c0de0006:	b662      	cpsie	i

    // Ensure exception will work as planned
    os_boot();
c0de0008:	f000 fa74 	bl	c0de04f4 <os_boot>
c0de000c:	ad01      	add	r5, sp, #4

    // Try catch block. Please read the docs for more information on how to use those!
    BEGIN_TRY {
        TRY {
c0de000e:	4628      	mov	r0, r5
c0de0010:	f000 fe78 	bl	c0de0d04 <setjmp>
c0de0014:	85a8      	strh	r0, [r5, #44]	; 0x2c
c0de0016:	0400      	lsls	r0, r0, #16
c0de0018:	d114      	bne.n	c0de0044 <main+0x44>
c0de001a:	a801      	add	r0, sp, #4
c0de001c:	f000 fc92 	bl	c0de0944 <try_context_set>
c0de0020:	900b      	str	r0, [sp, #44]	; 0x2c
// get API level
SYSCALL unsigned int get_api_level(void);

#ifndef HAVE_BOLOS
static inline void check_api_level(unsigned int apiLevel) {
  if (apiLevel < get_api_level()) {
c0de0022:	f000 fc43 	bl	c0de08ac <get_api_level>
c0de0026:	280d      	cmp	r0, #13
c0de0028:	d226      	bcs.n	c0de0078 <main+0x78>
c0de002a:	2001      	movs	r0, #1
c0de002c:	0201      	lsls	r1, r0, #8
            // Low-level black magic.
            check_api_level(CX_COMPAT_APILEVEL);

            // Check if we are called from the dashboard.
            if (!arg0) {
c0de002e:	2c00      	cmp	r4, #0
c0de0030:	d017      	beq.n	c0de0062 <main+0x62>
                // Not called from dashboard: called from the ethereum app!
                unsigned int *args = (unsigned int *) arg0;

                // If `ETH_PLUGIN_CHECK_PRESENCE` is set, this means the caller is just trying to
                // know whether this app exists or not. We can skip `dispatch_plugin_calls`.
                if (args[0] != ETH_PLUGIN_CHECK_PRESENCE) {
c0de0032:	6820      	ldr	r0, [r4, #0]
c0de0034:	31ff      	adds	r1, #255	; 0xff
c0de0036:	4288      	cmp	r0, r1
c0de0038:	d002      	beq.n	c0de0040 <main+0x40>
                    dispatch_plugin_calls(args[0], (void *) args[1]);
c0de003a:	6861      	ldr	r1, [r4, #4]
c0de003c:	f000 fa26 	bl	c0de048c <dispatch_plugin_calls>
                }

                // Call `os_lib_end`, go back to the ethereum app.
                os_lib_end();
c0de0040:	f000 fc50 	bl	c0de08e4 <os_lib_end>
            }
        }
        FINALLY {
c0de0044:	f000 fc72 	bl	c0de092c <try_context_get>
c0de0048:	a901      	add	r1, sp, #4
c0de004a:	4288      	cmp	r0, r1
c0de004c:	d102      	bne.n	c0de0054 <main+0x54>
c0de004e:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0de0050:	f000 fc78 	bl	c0de0944 <try_context_set>
c0de0054:	a801      	add	r0, sp, #4
        }
    }
    END_TRY;
c0de0056:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0de0058:	2800      	cmp	r0, #0
c0de005a:	d10b      	bne.n	c0de0074 <main+0x74>
c0de005c:	2000      	movs	r0, #0

    // Will not get reached.
    return 0;
}
c0de005e:	b010      	add	sp, #64	; 0x40
c0de0060:	bdb0      	pop	{r4, r5, r7, pc}
    libcall_params[2] = RUN_APPLICATION;
c0de0062:	900f      	str	r0, [sp, #60]	; 0x3c
    libcall_params[1] = 0x100;
c0de0064:	910e      	str	r1, [sp, #56]	; 0x38
    libcall_params[0] = (unsigned int) "Ethereum";
c0de0066:	4806      	ldr	r0, [pc, #24]	; (c0de0080 <main+0x80>)
c0de0068:	4478      	add	r0, pc
c0de006a:	900d      	str	r0, [sp, #52]	; 0x34
c0de006c:	a80d      	add	r0, sp, #52	; 0x34
    os_lib_call((unsigned int *) &libcall_params);
c0de006e:	f000 fc2b 	bl	c0de08c8 <os_lib_call>
c0de0072:	e7f3      	b.n	c0de005c <main+0x5c>
    END_TRY;
c0de0074:	f000 fa44 	bl	c0de0500 <os_longjmp>
c0de0078:	20ff      	movs	r0, #255	; 0xff
    os_sched_exit(-1);
c0de007a:	f000 fc3f 	bl	c0de08fc <os_sched_exit>
c0de007e:	46c0      	nop			; (mov r8, r8)
c0de0080:	00000dce 	.word	0x00000dce

c0de0084 <adjustDecimals>:

bool adjustDecimals(char *src,
                    uint32_t srcLength,
                    char *target,
                    uint32_t targetLength,
                    uint8_t decimals) {
c0de0084:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de0086:	b081      	sub	sp, #4
c0de0088:	4614      	mov	r4, r2
c0de008a:	460e      	mov	r6, r1
c0de008c:	4605      	mov	r5, r0
    uint32_t startOffset;
    uint32_t lastZeroOffset = 0;
    uint32_t offset = 0;
    if ((srcLength == 1) && (*src == '0')) {
c0de008e:	2901      	cmp	r1, #1
c0de0090:	d10a      	bne.n	c0de00a8 <adjustDecimals+0x24>
c0de0092:	7828      	ldrb	r0, [r5, #0]
c0de0094:	2830      	cmp	r0, #48	; 0x30
c0de0096:	d107      	bne.n	c0de00a8 <adjustDecimals+0x24>
        if (targetLength < 2) {
c0de0098:	2b02      	cmp	r3, #2
c0de009a:	d32e      	bcc.n	c0de00fa <adjustDecimals+0x76>
c0de009c:	2000      	movs	r0, #0
            return false;
        }
        target[0] = '0';
        target[1] = '\0';
c0de009e:	7060      	strb	r0, [r4, #1]
c0de00a0:	2030      	movs	r0, #48	; 0x30
        target[0] = '0';
c0de00a2:	7020      	strb	r0, [r4, #0]
c0de00a4:	2001      	movs	r0, #1
c0de00a6:	e061      	b.n	c0de016c <adjustDecimals+0xe8>
c0de00a8:	9806      	ldr	r0, [sp, #24]
        return true;
    }
    if (srcLength <= decimals) {
c0de00aa:	42b0      	cmp	r0, r6
c0de00ac:	d222      	bcs.n	c0de00f4 <adjustDecimals+0x70>
        }
        target[offset] = '\0';
    } else {
        uint32_t sourceOffset = 0;
        uint32_t delta = srcLength - decimals;
        if (targetLength < srcLength + 1 + 1) {
c0de00ae:	1cb1      	adds	r1, r6, #2
c0de00b0:	4299      	cmp	r1, r3
c0de00b2:	d822      	bhi.n	c0de00fa <adjustDecimals+0x76>
c0de00b4:	1a31      	subs	r1, r6, r0
            return false;
        }
        while (offset < delta) {
c0de00b6:	9100      	str	r1, [sp, #0]
c0de00b8:	d009      	beq.n	c0de00ce <adjustDecimals+0x4a>
c0de00ba:	4629      	mov	r1, r5
c0de00bc:	9b00      	ldr	r3, [sp, #0]
c0de00be:	4627      	mov	r7, r4
            target[offset++] = src[sourceOffset++];
c0de00c0:	780a      	ldrb	r2, [r1, #0]
c0de00c2:	703a      	strb	r2, [r7, #0]
        while (offset < delta) {
c0de00c4:	1c49      	adds	r1, r1, #1
c0de00c6:	1e5b      	subs	r3, r3, #1
c0de00c8:	1c7f      	adds	r7, r7, #1
c0de00ca:	2b00      	cmp	r3, #0
c0de00cc:	d1f8      	bne.n	c0de00c0 <adjustDecimals+0x3c>
        }
        if (decimals != 0) {
c0de00ce:	2800      	cmp	r0, #0
c0de00d0:	9a00      	ldr	r2, [sp, #0]
c0de00d2:	4611      	mov	r1, r2
c0de00d4:	d002      	beq.n	c0de00dc <adjustDecimals+0x58>
c0de00d6:	212e      	movs	r1, #46	; 0x2e
            target[offset++] = '.';
c0de00d8:	54a1      	strb	r1, [r4, r2]
c0de00da:	1c51      	adds	r1, r2, #1
        }
        startOffset = offset;
        while (sourceOffset < srcLength) {
c0de00dc:	42b2      	cmp	r2, r6
c0de00de:	d22a      	bcs.n	c0de0136 <adjustDecimals+0xb2>
c0de00e0:	1863      	adds	r3, r4, r1
c0de00e2:	18ad      	adds	r5, r5, r2
c0de00e4:	2200      	movs	r2, #0
            target[offset++] = src[sourceOffset++];
c0de00e6:	5cae      	ldrb	r6, [r5, r2]
c0de00e8:	549e      	strb	r6, [r3, r2]
        while (sourceOffset < srcLength) {
c0de00ea:	1c52      	adds	r2, r2, #1
c0de00ec:	4290      	cmp	r0, r2
c0de00ee:	d1fa      	bne.n	c0de00e6 <adjustDecimals+0x62>
c0de00f0:	188a      	adds	r2, r1, r2
c0de00f2:	e021      	b.n	c0de0138 <adjustDecimals+0xb4>
        if (targetLength < srcLength + 1 + 2 + delta) {
c0de00f4:	1cc1      	adds	r1, r0, #3
c0de00f6:	4299      	cmp	r1, r3
c0de00f8:	d901      	bls.n	c0de00fe <adjustDecimals+0x7a>
c0de00fa:	2000      	movs	r0, #0
c0de00fc:	e036      	b.n	c0de016c <adjustDecimals+0xe8>
c0de00fe:	1b87      	subs	r7, r0, r6
c0de0100:	202e      	movs	r0, #46	; 0x2e
        target[offset++] = '.';
c0de0102:	7060      	strb	r0, [r4, #1]
c0de0104:	2030      	movs	r0, #48	; 0x30
        target[offset++] = '0';
c0de0106:	7020      	strb	r0, [r4, #0]
        for (uint32_t i = 0; i < delta; i++) {
c0de0108:	2f00      	cmp	r7, #0
c0de010a:	d008      	beq.n	c0de011e <adjustDecimals+0x9a>
c0de010c:	1ca0      	adds	r0, r4, #2
c0de010e:	2230      	movs	r2, #48	; 0x30
            target[offset++] = '0';
c0de0110:	4639      	mov	r1, r7
c0de0112:	f000 fce9 	bl	c0de0ae8 <__aeabi_memset>
        for (uint32_t i = 0; i < delta; i++) {
c0de0116:	1cb9      	adds	r1, r7, #2
c0de0118:	1e7f      	subs	r7, r7, #1
c0de011a:	d1fd      	bne.n	c0de0118 <adjustDecimals+0x94>
c0de011c:	e000      	b.n	c0de0120 <adjustDecimals+0x9c>
c0de011e:	2102      	movs	r1, #2
        for (uint32_t i = 0; i < srcLength; i++) {
c0de0120:	2e00      	cmp	r6, #0
c0de0122:	d008      	beq.n	c0de0136 <adjustDecimals+0xb2>
c0de0124:	1862      	adds	r2, r4, r1
c0de0126:	2000      	movs	r0, #0
            target[offset++] = src[i];
c0de0128:	5c2b      	ldrb	r3, [r5, r0]
c0de012a:	5413      	strb	r3, [r2, r0]
        for (uint32_t i = 0; i < srcLength; i++) {
c0de012c:	1c40      	adds	r0, r0, #1
c0de012e:	4286      	cmp	r6, r0
c0de0130:	d1fa      	bne.n	c0de0128 <adjustDecimals+0xa4>
c0de0132:	180a      	adds	r2, r1, r0
c0de0134:	e000      	b.n	c0de0138 <adjustDecimals+0xb4>
c0de0136:	460a      	mov	r2, r1
c0de0138:	2500      	movs	r5, #0
c0de013a:	54a5      	strb	r5, [r4, r2]
c0de013c:	2001      	movs	r0, #1
        }
        target[offset] = '\0';
    }
    for (uint32_t i = startOffset; i < offset; i++) {
c0de013e:	4291      	cmp	r1, r2
c0de0140:	d214      	bcs.n	c0de016c <adjustDecimals+0xe8>
        if (target[i] == '0') {
c0de0142:	5c66      	ldrb	r6, [r4, r1]
c0de0144:	2d00      	cmp	r5, #0
c0de0146:	460b      	mov	r3, r1
c0de0148:	d000      	beq.n	c0de014c <adjustDecimals+0xc8>
c0de014a:	462b      	mov	r3, r5
c0de014c:	2e30      	cmp	r6, #48	; 0x30
c0de014e:	d000      	beq.n	c0de0152 <adjustDecimals+0xce>
c0de0150:	2300      	movs	r3, #0
    for (uint32_t i = startOffset; i < offset; i++) {
c0de0152:	1c49      	adds	r1, r1, #1
c0de0154:	428a      	cmp	r2, r1
c0de0156:	461d      	mov	r5, r3
c0de0158:	d1f3      	bne.n	c0de0142 <adjustDecimals+0xbe>
            }
        } else {
            lastZeroOffset = 0;
        }
    }
    if (lastZeroOffset != 0) {
c0de015a:	2b00      	cmp	r3, #0
c0de015c:	d006      	beq.n	c0de016c <adjustDecimals+0xe8>
c0de015e:	2100      	movs	r1, #0
        target[lastZeroOffset] = '\0';
c0de0160:	54e1      	strb	r1, [r4, r3]
        if (target[lastZeroOffset - 1] == '.') {
c0de0162:	1e5a      	subs	r2, r3, #1
c0de0164:	5ca3      	ldrb	r3, [r4, r2]
c0de0166:	2b2e      	cmp	r3, #46	; 0x2e
c0de0168:	d100      	bne.n	c0de016c <adjustDecimals+0xe8>
            target[lastZeroOffset - 1] = '\0';
c0de016a:	54a1      	strb	r1, [r4, r2]
        }
    }
    return true;
}
c0de016c:	b001      	add	sp, #4
c0de016e:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0de0170 <uint256_to_decimal>:

bool uint256_to_decimal(const uint8_t *value, size_t value_len, char *out, size_t out_len) {
c0de0170:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de0172:	b08b      	sub	sp, #44	; 0x2c
    if (value_len > INT256_LENGTH) {
c0de0174:	2920      	cmp	r1, #32
c0de0176:	d901      	bls.n	c0de017c <uint256_to_decimal+0xc>
c0de0178:	2000      	movs	r0, #0
c0de017a:	e057      	b.n	c0de022c <uint256_to_decimal+0xbc>
c0de017c:	4614      	mov	r4, r2
c0de017e:	460e      	mov	r6, r1
c0de0180:	4607      	mov	r7, r0
c0de0182:	ad03      	add	r5, sp, #12
c0de0184:	2120      	movs	r1, #32
        // value len is bigger than INT256_LENGTH ?!
        return false;
    }

    uint16_t n[16] = {0};
c0de0186:	4628      	mov	r0, r5
c0de0188:	9302      	str	r3, [sp, #8]
c0de018a:	f000 fc9f 	bl	c0de0acc <__aeabi_memclr>
    // Copy and right-align the number
    memcpy((uint8_t *) n + INT256_LENGTH - value_len, value, value_len);
c0de018e:	1ba8      	subs	r0, r5, r6
c0de0190:	3020      	adds	r0, #32
c0de0192:	4639      	mov	r1, r7
c0de0194:	4632      	mov	r2, r6
c0de0196:	f000 fc9f 	bl	c0de0ad8 <__aeabi_memcpy>
c0de019a:	9a02      	ldr	r2, [sp, #8]
c0de019c:	2000      	movs	r0, #0
c0de019e:	a903      	add	r1, sp, #12
} txContent_t;

static __attribute__((no_instrument_function)) inline int allzeroes(void *buf, size_t n) {
    uint8_t *p = (uint8_t *) buf;
    for (size_t i = 0; i < n; ++i) {
        if (p[i]) {
c0de01a0:	5c09      	ldrb	r1, [r1, r0]
c0de01a2:	2900      	cmp	r1, #0
c0de01a4:	d10a      	bne.n	c0de01bc <uint256_to_decimal+0x4c>
    for (size_t i = 0; i < n; ++i) {
c0de01a6:	1c40      	adds	r0, r0, #1
c0de01a8:	2820      	cmp	r0, #32
c0de01aa:	d1f8      	bne.n	c0de019e <uint256_to_decimal+0x2e>

    // Special case when value is 0
    if (allzeroes(n, INT256_LENGTH)) {
        if (out_len < 2) {
c0de01ac:	2a02      	cmp	r2, #2
c0de01ae:	d3e3      	bcc.n	c0de0178 <uint256_to_decimal+0x8>
            // Not enough space to hold "0" and \0.
            return false;
        }
        strlcpy(out, "0", out_len);
c0de01b0:	491f      	ldr	r1, [pc, #124]	; (c0de0230 <uint256_to_decimal+0xc0>)
c0de01b2:	4479      	add	r1, pc
c0de01b4:	4620      	mov	r0, r4
c0de01b6:	f000 fdbf 	bl	c0de0d38 <strlcpy>
c0de01ba:	e036      	b.n	c0de022a <uint256_to_decimal+0xba>
c0de01bc:	2000      	movs	r0, #0
c0de01be:	a903      	add	r1, sp, #12
        return true;
    }

    uint16_t *p = n;
    for (int i = 0; i < 16; i++) {
        n[i] = __builtin_bswap16(*p++);
c0de01c0:	5a0b      	ldrh	r3, [r1, r0]
c0de01c2:	ba5b      	rev16	r3, r3
c0de01c4:	520b      	strh	r3, [r1, r0]
    for (int i = 0; i < 16; i++) {
c0de01c6:	1c80      	adds	r0, r0, #2
c0de01c8:	2820      	cmp	r0, #32
c0de01ca:	d1f8      	bne.n	c0de01be <uint256_to_decimal+0x4e>
c0de01cc:	4613      	mov	r3, r2
c0de01ce:	2000      	movs	r0, #0
c0de01d0:	a903      	add	r1, sp, #12
        if (p[i]) {
c0de01d2:	5c09      	ldrb	r1, [r1, r0]
c0de01d4:	2900      	cmp	r1, #0
c0de01d6:	d103      	bne.n	c0de01e0 <uint256_to_decimal+0x70>
    for (size_t i = 0; i < n; ++i) {
c0de01d8:	1c40      	adds	r0, r0, #1
c0de01da:	2820      	cmp	r0, #32
c0de01dc:	d1f8      	bne.n	c0de01d0 <uint256_to_decimal+0x60>
c0de01de:	e01c      	b.n	c0de021a <uint256_to_decimal+0xaa>
    }
    int pos = out_len;
    while (!allzeroes(n, sizeof(n))) {
        if (pos == 0) {
c0de01e0:	2b00      	cmp	r3, #0
c0de01e2:	d0c9      	beq.n	c0de0178 <uint256_to_decimal+0x8>
c0de01e4:	9300      	str	r3, [sp, #0]
c0de01e6:	9401      	str	r4, [sp, #4]
c0de01e8:	2400      	movs	r4, #0
c0de01ea:	4620      	mov	r0, r4
c0de01ec:	af03      	add	r7, sp, #12
            return false;
        }
        pos -= 1;
        unsigned int carry = 0;
        for (int i = 0; i < 16; i++) {
            int rem = ((carry << 16) | n[i]) % 10;
c0de01ee:	5b39      	ldrh	r1, [r7, r4]
c0de01f0:	0400      	lsls	r0, r0, #16
c0de01f2:	1845      	adds	r5, r0, r1
c0de01f4:	260a      	movs	r6, #10
            n[i] = ((carry << 16) | n[i]) / 10;
c0de01f6:	4628      	mov	r0, r5
c0de01f8:	4631      	mov	r1, r6
c0de01fa:	f000 fbb1 	bl	c0de0960 <__udivsi3>
c0de01fe:	5338      	strh	r0, [r7, r4]
c0de0200:	4346      	muls	r6, r0
c0de0202:	1ba8      	subs	r0, r5, r6
        for (int i = 0; i < 16; i++) {
c0de0204:	1ca4      	adds	r4, r4, #2
c0de0206:	2c20      	cmp	r4, #32
c0de0208:	d1f0      	bne.n	c0de01ec <uint256_to_decimal+0x7c>
c0de020a:	2130      	movs	r1, #48	; 0x30
            carry = rem;
        }
        out[pos] = '0' + carry;
c0de020c:	4308      	orrs	r0, r1
c0de020e:	9b00      	ldr	r3, [sp, #0]
        pos -= 1;
c0de0210:	1e5b      	subs	r3, r3, #1
c0de0212:	9c01      	ldr	r4, [sp, #4]
        out[pos] = '0' + carry;
c0de0214:	54e0      	strb	r0, [r4, r3]
c0de0216:	9a02      	ldr	r2, [sp, #8]
c0de0218:	e7d9      	b.n	c0de01ce <uint256_to_decimal+0x5e>
    }
    memmove(out, out + pos, out_len - pos);
c0de021a:	18e1      	adds	r1, r4, r3
c0de021c:	1ad5      	subs	r5, r2, r3
c0de021e:	4620      	mov	r0, r4
c0de0220:	462a      	mov	r2, r5
c0de0222:	f000 fc5d 	bl	c0de0ae0 <__aeabi_memmove>
c0de0226:	2000      	movs	r0, #0
    out[out_len - pos] = 0;
c0de0228:	5560      	strb	r0, [r4, r5]
c0de022a:	2001      	movs	r0, #1
    return true;
}
c0de022c:	b00b      	add	sp, #44	; 0x2c
c0de022e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0de0230:	00000c8d 	.word	0x00000c8d

c0de0234 <amountToString>:
void amountToString(const uint8_t *amount,
                    uint8_t amount_size,
                    uint8_t decimals,
                    const char *ticker,
                    char *out_buffer,
                    uint8_t out_buffer_size) {
c0de0234:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de0236:	b09d      	sub	sp, #116	; 0x74
c0de0238:	9303      	str	r3, [sp, #12]
c0de023a:	9202      	str	r2, [sp, #8]
c0de023c:	460c      	mov	r4, r1
c0de023e:	4606      	mov	r6, r0
c0de0240:	af04      	add	r7, sp, #16
c0de0242:	2564      	movs	r5, #100	; 0x64
    char tmp_buffer[100] = {0};
c0de0244:	4638      	mov	r0, r7
c0de0246:	4629      	mov	r1, r5
c0de0248:	f000 fc40 	bl	c0de0acc <__aeabi_memclr>

    if (uint256_to_decimal(amount, amount_size, tmp_buffer, sizeof(tmp_buffer)) == false) {
c0de024c:	4630      	mov	r0, r6
c0de024e:	4621      	mov	r1, r4
c0de0250:	463a      	mov	r2, r7
c0de0252:	462b      	mov	r3, r5
c0de0254:	f7ff ff8c 	bl	c0de0170 <uint256_to_decimal>
c0de0258:	2800      	cmp	r0, #0
c0de025a:	d026      	beq.n	c0de02aa <amountToString+0x76>
c0de025c:	9d23      	ldr	r5, [sp, #140]	; 0x8c
c0de025e:	9e22      	ldr	r6, [sp, #136]	; 0x88
c0de0260:	af04      	add	r7, sp, #16
c0de0262:	2164      	movs	r1, #100	; 0x64
        THROW(EXCEPTION_OVERFLOW);
    }

    uint8_t amount_len = strnlen(tmp_buffer, sizeof(tmp_buffer));
c0de0264:	4638      	mov	r0, r7
c0de0266:	f000 fd8d 	bl	c0de0d84 <strnlen>
c0de026a:	9001      	str	r0, [sp, #4]
c0de026c:	210c      	movs	r1, #12
    uint8_t ticker_len = strnlen(ticker, MAX_TICKER_LEN);
c0de026e:	9803      	ldr	r0, [sp, #12]
c0de0270:	f000 fd88 	bl	c0de0d84 <strnlen>

    memcpy(out_buffer, ticker, MIN(out_buffer_size, ticker_len));
c0de0274:	b2c4      	uxtb	r4, r0
c0de0276:	42ac      	cmp	r4, r5
c0de0278:	462a      	mov	r2, r5
c0de027a:	d800      	bhi.n	c0de027e <amountToString+0x4a>
c0de027c:	4622      	mov	r2, r4
c0de027e:	4630      	mov	r0, r6
c0de0280:	9903      	ldr	r1, [sp, #12]
c0de0282:	f000 fc29 	bl	c0de0ad8 <__aeabi_memcpy>

    if (adjustDecimals(tmp_buffer,
c0de0286:	9802      	ldr	r0, [sp, #8]
c0de0288:	9000      	str	r0, [sp, #0]
                       amount_len,
                       out_buffer + ticker_len,
c0de028a:	1932      	adds	r2, r6, r4
                       out_buffer_size - ticker_len - 1,
c0de028c:	43e0      	mvns	r0, r4
c0de028e:	1943      	adds	r3, r0, r5
                       amount_len,
c0de0290:	9801      	ldr	r0, [sp, #4]
c0de0292:	b2c1      	uxtb	r1, r0
    if (adjustDecimals(tmp_buffer,
c0de0294:	4638      	mov	r0, r7
c0de0296:	f7ff fef5 	bl	c0de0084 <adjustDecimals>
c0de029a:	2800      	cmp	r0, #0
c0de029c:	d005      	beq.n	c0de02aa <amountToString+0x76>
                       decimals) == false) {
        THROW(EXCEPTION_OVERFLOW);
    }

    out_buffer[out_buffer_size - 1] = '\0';
c0de029e:	19a8      	adds	r0, r5, r6
c0de02a0:	1e40      	subs	r0, r0, #1
c0de02a2:	2100      	movs	r1, #0
c0de02a4:	7001      	strb	r1, [r0, #0]
}
c0de02a6:	b01d      	add	sp, #116	; 0x74
c0de02a8:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0de02aa:	2007      	movs	r0, #7
c0de02ac:	f000 f928 	bl	c0de0500 <os_longjmp>

c0de02b0 <handle_finalize>:
#include "ricochet_plugin.h"

void handle_finalize(void *parameters) {
c0de02b0:	2104      	movs	r1, #4
    context_t *context = (context_t *) msg->pluginContext;

    msg->uiType = ETH_UI_TYPE_GENERIC;

    msg->numScreens = 2;
    msg->result = ETH_PLUGIN_RESULT_OK;
c0de02b2:	7781      	strb	r1, [r0, #30]
c0de02b4:	4901      	ldr	r1, [pc, #4]	; (c0de02bc <handle_finalize+0xc>)
    msg->uiType = ETH_UI_TYPE_GENERIC;
c0de02b6:	8381      	strh	r1, [r0, #28]
}
c0de02b8:	4770      	bx	lr
c0de02ba:	46c0      	nop			; (mov r8, r8)
c0de02bc:	00000202 	.word	0x00000202

c0de02c0 <handle_init_contract>:
#include "ricochet_plugin.h"

// Called once to init.
void handle_init_contract(void *parameters) {
c0de02c0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de02c2:	b081      	sub	sp, #4
c0de02c4:	4604      	mov	r4, r0
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *) parameters;

    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_LATEST) {
c0de02c6:	7800      	ldrb	r0, [r0, #0]
c0de02c8:	2803      	cmp	r0, #3
c0de02ca:	d107      	bne.n	c0de02dc <handle_init_contract+0x1c>
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
        return;
    }

    if (msg->pluginContextLength < sizeof(context_t)) {
c0de02cc:	6920      	ldr	r0, [r4, #16]
c0de02ce:	2829      	cmp	r0, #41	; 0x29
c0de02d0:	d807      	bhi.n	c0de02e2 <handle_init_contract+0x22>
        PRINTF("Plugin parameters structure is bigger than allowed size\n");
c0de02d2:	4821      	ldr	r0, [pc, #132]	; (c0de0358 <handle_init_contract+0x98>)
c0de02d4:	4478      	add	r0, pc
c0de02d6:	f000 f935 	bl	c0de0544 <mcu_usb_printf>
c0de02da:	e03b      	b.n	c0de0354 <handle_init_contract+0x94>
c0de02dc:	2001      	movs	r0, #1
c0de02de:	7060      	strb	r0, [r4, #1]
c0de02e0:	e038      	b.n	c0de0354 <handle_init_contract+0x94>
        // msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    context_t *context = (context_t *) msg->pluginContext;
c0de02e2:	68e5      	ldr	r5, [r4, #12]
c0de02e4:	212a      	movs	r1, #42	; 0x2a

    memset(context, 0, sizeof(*context));
c0de02e6:	4628      	mov	r0, r5
c0de02e8:	f000 fbf0 	bl	c0de0acc <__aeabi_memclr>
c0de02ec:	3526      	adds	r5, #38	; 0x26
c0de02ee:	2000      	movs	r0, #0
c0de02f0:	4e1a      	ldr	r6, [pc, #104]	; (c0de035c <handle_init_contract+0x9c>)
c0de02f2:	447e      	add	r6, pc

    uint8_t i;
    for (i = 0; i < NUM_SELECTORS; i++) {
c0de02f4:	2801      	cmp	r0, #1
c0de02f6:	d01e      	beq.n	c0de0336 <handle_init_contract+0x76>
c0de02f8:	4607      	mov	r7, r0
        if (memcmp((uint8_t *) PIC(RICOCHET_SELECTORS[i]), msg->selector, SELECTOR_SIZE) == 0) {
c0de02fa:	0080      	lsls	r0, r0, #2
c0de02fc:	5830      	ldr	r0, [r6, r0]
c0de02fe:	f000 fab1 	bl	c0de0864 <pic>
c0de0302:	7801      	ldrb	r1, [r0, #0]
c0de0304:	7842      	ldrb	r2, [r0, #1]
c0de0306:	0212      	lsls	r2, r2, #8
c0de0308:	1851      	adds	r1, r2, r1
c0de030a:	7882      	ldrb	r2, [r0, #2]
c0de030c:	78c0      	ldrb	r0, [r0, #3]
c0de030e:	0200      	lsls	r0, r0, #8
c0de0310:	1880      	adds	r0, r0, r2
c0de0312:	0400      	lsls	r0, r0, #16
c0de0314:	1841      	adds	r1, r0, r1
c0de0316:	6960      	ldr	r0, [r4, #20]
c0de0318:	7802      	ldrb	r2, [r0, #0]
c0de031a:	7843      	ldrb	r3, [r0, #1]
c0de031c:	021b      	lsls	r3, r3, #8
c0de031e:	189a      	adds	r2, r3, r2
c0de0320:	7883      	ldrb	r3, [r0, #2]
c0de0322:	78c0      	ldrb	r0, [r0, #3]
c0de0324:	0200      	lsls	r0, r0, #8
c0de0326:	18c0      	adds	r0, r0, r3
c0de0328:	0400      	lsls	r0, r0, #16
c0de032a:	1882      	adds	r2, r0, r2
c0de032c:	2001      	movs	r0, #1
c0de032e:	4291      	cmp	r1, r2
c0de0330:	d1e0      	bne.n	c0de02f4 <handle_init_contract+0x34>
            context->selectorIndex = i;
c0de0332:	70af      	strb	r7, [r5, #2]
c0de0334:	e00a      	b.n	c0de034c <handle_init_contract+0x8c>
c0de0336:	2001      	movs	r0, #1
            break;
        }
    }
    if (i == NUM_SELECTORS) {
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
c0de0338:	7060      	strb	r0, [r4, #1]
    }

    // Set `next_param` to be the first field we expect to parse.
    switch (context->selectorIndex) {
c0de033a:	78a9      	ldrb	r1, [r5, #2]
c0de033c:	2900      	cmp	r1, #0
c0de033e:	d005      	beq.n	c0de034c <handle_init_contract+0x8c>
        case UPGRADE:
            context->next_param = AMOUNT;
            break;
        default:
            PRINTF("Missing selectorIndex: %d\n", context->selectorIndex);
c0de0340:	4807      	ldr	r0, [pc, #28]	; (c0de0360 <handle_init_contract+0xa0>)
c0de0342:	4478      	add	r0, pc
c0de0344:	f000 f8fe 	bl	c0de0544 <mcu_usb_printf>
c0de0348:	2000      	movs	r0, #0
c0de034a:	e7c8      	b.n	c0de02de <handle_init_contract+0x1e>
c0de034c:	2004      	movs	r0, #4
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
c0de034e:	7060      	strb	r0, [r4, #1]
c0de0350:	2000      	movs	r0, #0
            context->next_param = AMOUNT;
c0de0352:	7028      	strb	r0, [r5, #0]
}
c0de0354:	b001      	add	sp, #4
c0de0356:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0de0358:	00000ae0 	.word	0x00000ae0
c0de035c:	00000c1a 	.word	0x00000c1a
c0de0360:	00000baa 	.word	0x00000baa

c0de0364 <handle_provide_parameter>:
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
}

void handle_provide_parameter(void *parameters) {
c0de0364:	b570      	push	{r4, r5, r6, lr}
c0de0366:	4604      	mov	r4, r0
c0de0368:	2004      	movs	r0, #4
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    msg->result = ETH_PLUGIN_RESULT_OK;
c0de036a:	7520      	strb	r0, [r4, #20]
    context_t *context = (context_t *) msg->pluginContext;
c0de036c:	68a0      	ldr	r0, [r4, #8]
c0de036e:	2124      	movs	r1, #36	; 0x24

    if (context->skip) {
c0de0370:	5c41      	ldrb	r1, [r0, r1]
c0de0372:	4605      	mov	r5, r0
c0de0374:	3524      	adds	r5, #36	; 0x24
c0de0376:	2900      	cmp	r1, #0
c0de0378:	d002      	beq.n	c0de0380 <handle_provide_parameter+0x1c>
        // Skip this step, and don't forget to decrease skipping counter.
        context->skip--;
c0de037a:	1e48      	subs	r0, r1, #1
c0de037c:	7028      	strb	r0, [r5, #0]
                PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                break;
        }
    }
}
c0de037e:	bd70      	pop	{r4, r5, r6, pc}
        if ((context->offset) && msg->parameterOffset != context->checkpoint + context->offset) {
c0de0380:	8c01      	ldrh	r1, [r0, #32]
c0de0382:	2900      	cmp	r1, #0
c0de0384:	d004      	beq.n	c0de0390 <handle_provide_parameter+0x2c>
c0de0386:	8c42      	ldrh	r2, [r0, #34]	; 0x22
c0de0388:	1856      	adds	r6, r2, r1
c0de038a:	6923      	ldr	r3, [r4, #16]
c0de038c:	42b3      	cmp	r3, r6
c0de038e:	d10a      	bne.n	c0de03a6 <handle_provide_parameter+0x42>
c0de0390:	2600      	movs	r6, #0
        context->offset = 0;  // Reset offset
c0de0392:	8406      	strh	r6, [r0, #32]
        switch (context->selectorIndex) {
c0de0394:	7929      	ldrb	r1, [r5, #4]
c0de0396:	2900      	cmp	r1, #0
c0de0398:	d00a      	beq.n	c0de03b0 <handle_provide_parameter+0x4c>
                PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
c0de039a:	4810      	ldr	r0, [pc, #64]	; (c0de03dc <handle_provide_parameter+0x78>)
c0de039c:	4478      	add	r0, pc
c0de039e:	f000 f8d1 	bl	c0de0544 <mcu_usb_printf>
c0de03a2:	7526      	strb	r6, [r4, #20]
}
c0de03a4:	bd70      	pop	{r4, r5, r6, pc}
            PRINTF("offset: %d, checkpoint: %d, parameterOffset: %d\n",
c0de03a6:	480b      	ldr	r0, [pc, #44]	; (c0de03d4 <handle_provide_parameter+0x70>)
c0de03a8:	4478      	add	r0, pc
c0de03aa:	f000 f8cb 	bl	c0de0544 <mcu_usb_printf>
}
c0de03ae:	bd70      	pop	{r4, r5, r6, pc}
    switch (context->next_param) {
c0de03b0:	78a9      	ldrb	r1, [r5, #2]
c0de03b2:	2901      	cmp	r1, #1
c0de03b4:	d0f6      	beq.n	c0de03a4 <handle_provide_parameter+0x40>
c0de03b6:	2900      	cmp	r1, #0
c0de03b8:	d106      	bne.n	c0de03c8 <handle_provide_parameter+0x64>
c0de03ba:	2120      	movs	r1, #32
    memcpy(dst, src, PARAMETER_LENGTH);
c0de03bc:	460a      	mov	r2, r1
c0de03be:	f000 fb8b 	bl	c0de0ad8 <__aeabi_memcpy>
c0de03c2:	2001      	movs	r0, #1
            context->next_param = NONE;
c0de03c4:	70a8      	strb	r0, [r5, #2]
}
c0de03c6:	bd70      	pop	{r4, r5, r6, pc}
            PRINTF("Param not supported\n");
c0de03c8:	4803      	ldr	r0, [pc, #12]	; (c0de03d8 <handle_provide_parameter+0x74>)
c0de03ca:	4478      	add	r0, pc
c0de03cc:	f000 f8ba 	bl	c0de0544 <mcu_usb_printf>
c0de03d0:	e7e7      	b.n	c0de03a2 <handle_provide_parameter+0x3e>
c0de03d2:	46c0      	nop			; (mov r8, r8)
c0de03d4:	00000a99 	.word	0x00000a99
c0de03d8:	00000a57 	.word	0x00000a57
c0de03dc:	00000af6 	.word	0x00000af6

c0de03e0 <handle_query_contract_id>:
#include "ricochet_plugin.h"

void handle_query_contract_id(void *parameters) {
c0de03e0:	b5b0      	push	{r4, r5, r7, lr}
c0de03e2:	4604      	mov	r4, r0
    ethQueryContractID_t *msg = (ethQueryContractID_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;
c0de03e4:	6885      	ldr	r5, [r0, #8]

    strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);
c0de03e6:	68c0      	ldr	r0, [r0, #12]
c0de03e8:	6922      	ldr	r2, [r4, #16]
c0de03ea:	490b      	ldr	r1, [pc, #44]	; (c0de0418 <handle_query_contract_id+0x38>)
c0de03ec:	4479      	add	r1, pc
c0de03ee:	f000 fca3 	bl	c0de0d38 <strlcpy>
c0de03f2:	2028      	movs	r0, #40	; 0x28

    switch (context->selectorIndex) {
c0de03f4:	5c29      	ldrb	r1, [r5, r0]
c0de03f6:	2900      	cmp	r1, #0
c0de03f8:	d005      	beq.n	c0de0406 <handle_query_contract_id+0x26>
        case UPGRADE:
            strlcpy(msg->version, "Updrage", msg->versionLength);
            break;
        default:
            PRINTF("Selector index: %d not supported\n", context->selectorIndex);
c0de03fa:	4809      	ldr	r0, [pc, #36]	; (c0de0420 <handle_query_contract_id+0x40>)
c0de03fc:	4478      	add	r0, pc
c0de03fe:	f000 f8a1 	bl	c0de0544 <mcu_usb_printf>
c0de0402:	2000      	movs	r0, #0
c0de0404:	e006      	b.n	c0de0414 <handle_query_contract_id+0x34>
            strlcpy(msg->version, "Updrage", msg->versionLength);
c0de0406:	6960      	ldr	r0, [r4, #20]
c0de0408:	69a2      	ldr	r2, [r4, #24]
c0de040a:	4904      	ldr	r1, [pc, #16]	; (c0de041c <handle_query_contract_id+0x3c>)
c0de040c:	4479      	add	r1, pc
c0de040e:	f000 fc93 	bl	c0de0d38 <strlcpy>
c0de0412:	2004      	movs	r0, #4
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }
    msg->result = ETH_PLUGIN_RESULT_OK;
c0de0414:	7720      	strb	r0, [r4, #28]
c0de0416:	bdb0      	pop	{r4, r5, r7, pc}
c0de0418:	00000a01 	.word	0x00000a01
c0de041c:	000009a0 	.word	0x000009a0
c0de0420:	000009fa 	.word	0x000009fa

c0de0424 <handle_query_contract_ui>:
            return ERROR;
            break;
    }
}

void handle_query_contract_ui(void *parameters) {
c0de0424:	b5b0      	push	{r4, r5, r7, lr}
c0de0426:	b082      	sub	sp, #8
c0de0428:	4604      	mov	r4, r0
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;
c0de042a:	6885      	ldr	r5, [r0, #8]

    memset(msg->title, 0, msg->titleLength);
c0de042c:	69c0      	ldr	r0, [r0, #28]
c0de042e:	6a21      	ldr	r1, [r4, #32]
c0de0430:	f000 fb4c 	bl	c0de0acc <__aeabi_memclr>
    memset(msg->msg, 0, msg->msgLength);
c0de0434:	6a60      	ldr	r0, [r4, #36]	; 0x24
c0de0436:	6aa1      	ldr	r1, [r4, #40]	; 0x28
c0de0438:	f000 fb48 	bl	c0de0acc <__aeabi_memclr>
c0de043c:	202c      	movs	r0, #44	; 0x2c
c0de043e:	2104      	movs	r1, #4
    msg->result = ETH_PLUGIN_RESULT_OK;
c0de0440:	5421      	strb	r1, [r4, r0]
    uint8_t index = msg->screenIndex;
c0de0442:	7b20      	ldrb	r0, [r4, #12]

    screens_t screen = get_screen(msg, context);

    switch (screen) {
c0de0444:	2800      	cmp	r0, #0
c0de0446:	d007      	beq.n	c0de0458 <handle_query_contract_ui+0x34>
c0de0448:	342c      	adds	r4, #44	; 0x2c
        case AMOUNT_SCREEN:
            set_amount_ui(msg, context);
            break;
        default:
            PRINTF("Received an invalid screenIndex\n");
c0de044a:	480f      	ldr	r0, [pc, #60]	; (c0de0488 <handle_query_contract_ui+0x64>)
c0de044c:	4478      	add	r0, pc
c0de044e:	f000 f879 	bl	c0de0544 <mcu_usb_printf>
c0de0452:	2000      	movs	r0, #0
            msg->result = ETH_PLUGIN_RESULT_ERROR;
c0de0454:	7020      	strb	r0, [r4, #0]
c0de0456:	e011      	b.n	c0de047c <handle_query_contract_ui+0x58>
    strlcpy(msg->title, "Amount", msg->titleLength);
c0de0458:	69e0      	ldr	r0, [r4, #28]
c0de045a:	6a22      	ldr	r2, [r4, #32]
c0de045c:	4908      	ldr	r1, [pc, #32]	; (c0de0480 <handle_query_contract_ui+0x5c>)
c0de045e:	4479      	add	r1, pc
c0de0460:	f000 fc6a 	bl	c0de0d38 <strlcpy>
c0de0464:	2028      	movs	r0, #40	; 0x28
    amountToString(context->amount, sizeof(context->amount), 0, "", msg->msg, msg->msgLength);
c0de0466:	5c20      	ldrb	r0, [r4, r0]
c0de0468:	6a61      	ldr	r1, [r4, #36]	; 0x24
c0de046a:	9100      	str	r1, [sp, #0]
c0de046c:	9001      	str	r0, [sp, #4]
c0de046e:	2120      	movs	r1, #32
c0de0470:	2200      	movs	r2, #0
c0de0472:	4b04      	ldr	r3, [pc, #16]	; (c0de0484 <handle_query_contract_ui+0x60>)
c0de0474:	447b      	add	r3, pc
c0de0476:	4628      	mov	r0, r5
c0de0478:	f7ff fedc 	bl	c0de0234 <amountToString>
            return;
    }
}
c0de047c:	b002      	add	sp, #8
c0de047e:	bdb0      	pop	{r4, r5, r7, pc}
c0de0480:	000009ba 	.word	0x000009ba
c0de0484:	00000a77 	.word	0x00000a77
c0de0488:	00000a7e 	.word	0x00000a7e

c0de048c <dispatch_plugin_calls>:
void dispatch_plugin_calls(int message, void *parameters) {
c0de048c:	b580      	push	{r7, lr}
c0de048e:	4602      	mov	r2, r0
c0de0490:	2081      	movs	r0, #129	; 0x81
c0de0492:	0040      	lsls	r0, r0, #1
    switch (message) {
c0de0494:	4282      	cmp	r2, r0
c0de0496:	dd0f      	ble.n	c0de04b8 <dispatch_plugin_calls+0x2c>
c0de0498:	20ff      	movs	r0, #255	; 0xff
c0de049a:	4603      	mov	r3, r0
c0de049c:	3304      	adds	r3, #4
c0de049e:	429a      	cmp	r2, r3
c0de04a0:	d014      	beq.n	c0de04cc <dispatch_plugin_calls+0x40>
c0de04a2:	3006      	adds	r0, #6
c0de04a4:	4282      	cmp	r2, r0
c0de04a6:	d015      	beq.n	c0de04d4 <dispatch_plugin_calls+0x48>
c0de04a8:	2083      	movs	r0, #131	; 0x83
c0de04aa:	0040      	lsls	r0, r0, #1
c0de04ac:	4282      	cmp	r2, r0
c0de04ae:	d119      	bne.n	c0de04e4 <dispatch_plugin_calls+0x58>
            handle_query_contract_ui(parameters);
c0de04b0:	4608      	mov	r0, r1
c0de04b2:	f7ff ffb7 	bl	c0de0424 <handle_query_contract_ui>
}
c0de04b6:	bd80      	pop	{r7, pc}
c0de04b8:	23ff      	movs	r3, #255	; 0xff
c0de04ba:	3302      	adds	r3, #2
    switch (message) {
c0de04bc:	429a      	cmp	r2, r3
c0de04be:	d00d      	beq.n	c0de04dc <dispatch_plugin_calls+0x50>
c0de04c0:	4282      	cmp	r2, r0
c0de04c2:	d10f      	bne.n	c0de04e4 <dispatch_plugin_calls+0x58>
            handle_provide_parameter(parameters);
c0de04c4:	4608      	mov	r0, r1
c0de04c6:	f7ff ff4d 	bl	c0de0364 <handle_provide_parameter>
}
c0de04ca:	bd80      	pop	{r7, pc}
            handle_finalize(parameters);
c0de04cc:	4608      	mov	r0, r1
c0de04ce:	f7ff feef 	bl	c0de02b0 <handle_finalize>
}
c0de04d2:	bd80      	pop	{r7, pc}
            handle_query_contract_id(parameters);
c0de04d4:	4608      	mov	r0, r1
c0de04d6:	f7ff ff83 	bl	c0de03e0 <handle_query_contract_id>
}
c0de04da:	bd80      	pop	{r7, pc}
            handle_init_contract(parameters);
c0de04dc:	4608      	mov	r0, r1
c0de04de:	f7ff feef 	bl	c0de02c0 <handle_init_contract>
}
c0de04e2:	bd80      	pop	{r7, pc}
            PRINTF("Unhandled message %d\n", message);
c0de04e4:	4802      	ldr	r0, [pc, #8]	; (c0de04f0 <dispatch_plugin_calls+0x64>)
c0de04e6:	4478      	add	r0, pc
c0de04e8:	4611      	mov	r1, r2
c0de04ea:	f000 f82b 	bl	c0de0544 <mcu_usb_printf>
}
c0de04ee:	bd80      	pop	{r7, pc}
c0de04f0:	000009ce 	.word	0x000009ce

c0de04f4 <os_boot>:

// apdu buffer must hold a complete apdu to avoid troubles
unsigned char G_io_apdu_buffer[IO_APDU_BUFFER_SIZE];

#ifndef BOLOS_OS_UPGRADER_APP
void os_boot(void) {
c0de04f4:	b580      	push	{r7, lr}
c0de04f6:	2000      	movs	r0, #0
  // // TODO patch entry point when romming (f)
  // // set the default try context to nothing
#ifndef HAVE_BOLOS
  try_context_set(NULL);
c0de04f8:	f000 fa24 	bl	c0de0944 <try_context_set>
#endif // HAVE_BOLOS
}
c0de04fc:	bd80      	pop	{r7, pc}
c0de04fe:	d4d4      	bmi.n	c0de04aa <dispatch_plugin_calls+0x1e>

c0de0500 <os_longjmp>:
  }
  return xoracc;
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
c0de0500:	4604      	mov	r4, r0
#ifdef HAVE_PRINTF  
  unsigned int lr_val;
  __asm volatile("mov %0, lr" :"=r"(lr_val));
c0de0502:	4672      	mov	r2, lr
  PRINTF("exception[%d]: LR=0x%08X\n", exception, lr_val);
c0de0504:	4804      	ldr	r0, [pc, #16]	; (c0de0518 <os_longjmp+0x18>)
c0de0506:	4478      	add	r0, pc
c0de0508:	4621      	mov	r1, r4
c0de050a:	f000 f81b 	bl	c0de0544 <mcu_usb_printf>
#endif // HAVE_PRINTF
  longjmp(try_context_get()->jmp_buf, exception);
c0de050e:	f000 fa0d 	bl	c0de092c <try_context_get>
c0de0512:	4621      	mov	r1, r4
c0de0514:	f000 fc02 	bl	c0de0d1c <longjmp>
c0de0518:	0000096c 	.word	0x0000096c

c0de051c <mcu_usb_prints>:
  return ret;
}
#endif // !defined(APP_UX)

#ifdef HAVE_PRINTF
void mcu_usb_prints(const char* str, unsigned int charcount) {
c0de051c:	b5b0      	push	{r4, r5, r7, lr}
c0de051e:	b082      	sub	sp, #8
c0de0520:	460c      	mov	r4, r1
c0de0522:	4605      	mov	r5, r0
c0de0524:	a801      	add	r0, sp, #4
  unsigned char buf[4];

  buf[0] = SEPROXYHAL_TAG_PRINTF;
  buf[1] = charcount >> 8;
  buf[2] = charcount;
c0de0526:	7081      	strb	r1, [r0, #2]
c0de0528:	215f      	movs	r1, #95	; 0x5f
  buf[0] = SEPROXYHAL_TAG_PRINTF;
c0de052a:	7001      	strb	r1, [r0, #0]
  buf[1] = charcount >> 8;
c0de052c:	0a21      	lsrs	r1, r4, #8
c0de052e:	7041      	strb	r1, [r0, #1]
c0de0530:	2103      	movs	r1, #3
  io_seproxyhal_spi_send(buf, 3);
c0de0532:	f000 f9ef 	bl	c0de0914 <io_seph_send>
  io_seproxyhal_spi_send((unsigned char*)str, charcount);
c0de0536:	b2a1      	uxth	r1, r4
c0de0538:	4628      	mov	r0, r5
c0de053a:	f000 f9eb 	bl	c0de0914 <io_seph_send>
}
c0de053e:	b002      	add	sp, #8
c0de0540:	bdb0      	pop	{r4, r5, r7, pc}
c0de0542:	d4d4      	bmi.n	c0de04ee <dispatch_plugin_calls+0x62>

c0de0544 <mcu_usb_printf>:
#include "usbd_def.h"
#include "usbd_core.h"

void screen_printf(const char* format, ...) __attribute__ ((weak, alias ("mcu_usb_printf")));

void mcu_usb_printf(const char* format, ...) {
c0de0544:	b083      	sub	sp, #12
c0de0546:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de0548:	b08c      	sub	sp, #48	; 0x30
c0de054a:	ac11      	add	r4, sp, #68	; 0x44
c0de054c:	c40e      	stmia	r4!, {r1, r2, r3}
    char cStrlenSet;

    //
    // Check the arguments.
    //
    if(format == 0) {
c0de054e:	2800      	cmp	r0, #0
c0de0550:	d100      	bne.n	c0de0554 <mcu_usb_printf+0x10>
c0de0552:	e16c      	b.n	c0de082e <mcu_usb_printf+0x2ea>
c0de0554:	4604      	mov	r4, r0
c0de0556:	a811      	add	r0, sp, #68	; 0x44
    }

    //
    // Start the varargs processing.
    //
    va_start(vaArgP, format);
c0de0558:	9006      	str	r0, [sp, #24]

    //
    // Loop while there are more characters in the string.
    //
    while(*format)
c0de055a:	7820      	ldrb	r0, [r4, #0]
c0de055c:	2800      	cmp	r0, #0
c0de055e:	d100      	bne.n	c0de0562 <mcu_usb_printf+0x1e>
c0de0560:	e165      	b.n	c0de082e <mcu_usb_printf+0x2ea>
c0de0562:	2500      	movs	r5, #0
    {
        //
        // Find the first non-% character, or the end of the string.
        //
        for(ulIdx = 0; (format[ulIdx] != '%') && (format[ulIdx] != '\0');
c0de0564:	2800      	cmp	r0, #0
c0de0566:	d005      	beq.n	c0de0574 <mcu_usb_printf+0x30>
c0de0568:	2825      	cmp	r0, #37	; 0x25
c0de056a:	d003      	beq.n	c0de0574 <mcu_usb_printf+0x30>
c0de056c:	1960      	adds	r0, r4, r5
c0de056e:	7840      	ldrb	r0, [r0, #1]
            ulIdx++)
c0de0570:	1c6d      	adds	r5, r5, #1
c0de0572:	e7f7      	b.n	c0de0564 <mcu_usb_printf+0x20>
        }

        //
        // Write this portion of the string.
        //
        mcu_usb_prints(format, ulIdx);
c0de0574:	4620      	mov	r0, r4
c0de0576:	4629      	mov	r1, r5
c0de0578:	f7ff ffd0 	bl	c0de051c <mcu_usb_prints>
        format += ulIdx;

        //
        // See if the next character is a %.
        //
        if(*format == '%')
c0de057c:	5d60      	ldrb	r0, [r4, r5]
c0de057e:	2825      	cmp	r0, #37	; 0x25
c0de0580:	d001      	beq.n	c0de0586 <mcu_usb_printf+0x42>
c0de0582:	1964      	adds	r4, r4, r5
c0de0584:	e7ea      	b.n	c0de055c <mcu_usb_printf+0x18>
            ulCount = 0;
            cFill = ' ';
            ulStrlen = 0;
            cStrlenSet = 0;
            ulCap = 0;
            ulBase = 10;
c0de0586:	1960      	adds	r0, r4, r5
c0de0588:	1c44      	adds	r4, r0, #1
c0de058a:	2600      	movs	r6, #0
c0de058c:	2020      	movs	r0, #32
c0de058e:	9004      	str	r0, [sp, #16]
c0de0590:	200a      	movs	r0, #10
c0de0592:	9605      	str	r6, [sp, #20]
c0de0594:	9602      	str	r6, [sp, #8]
c0de0596:	4633      	mov	r3, r6
c0de0598:	4619      	mov	r1, r3
again:

            //
            // Determine how to handle the next character.
            //
            switch(*format++)
c0de059a:	7822      	ldrb	r2, [r4, #0]
c0de059c:	1c64      	adds	r4, r4, #1
c0de059e:	2300      	movs	r3, #0
c0de05a0:	2a2d      	cmp	r2, #45	; 0x2d
c0de05a2:	d0f9      	beq.n	c0de0598 <mcu_usb_printf+0x54>
c0de05a4:	2a47      	cmp	r2, #71	; 0x47
c0de05a6:	dc13      	bgt.n	c0de05d0 <mcu_usb_printf+0x8c>
c0de05a8:	2a2f      	cmp	r2, #47	; 0x2f
c0de05aa:	dd1e      	ble.n	c0de05ea <mcu_usb_printf+0xa6>
c0de05ac:	4613      	mov	r3, r2
c0de05ae:	3b30      	subs	r3, #48	; 0x30
c0de05b0:	2b0a      	cmp	r3, #10
c0de05b2:	d300      	bcc.n	c0de05b6 <mcu_usb_printf+0x72>
c0de05b4:	e0b1      	b.n	c0de071a <mcu_usb_printf+0x1d6>
c0de05b6:	2330      	movs	r3, #48	; 0x30
                {
                    //
                    // If this is a zero, and it is the first digit, then the
                    // fill character is a zero instead of a space.
                    //
                    if((format[-1] == '0') && (ulCount == 0))
c0de05b8:	4617      	mov	r7, r2
c0de05ba:	405f      	eors	r7, r3
c0de05bc:	4337      	orrs	r7, r6
c0de05be:	d000      	beq.n	c0de05c2 <mcu_usb_printf+0x7e>
c0de05c0:	9b04      	ldr	r3, [sp, #16]
c0de05c2:	270a      	movs	r7, #10
                    }

                    //
                    // Update the digit count.
                    //
                    ulCount *= 10;
c0de05c4:	4377      	muls	r7, r6
                    ulCount += format[-1] - '0';
c0de05c6:	18be      	adds	r6, r7, r2
c0de05c8:	3e30      	subs	r6, #48	; 0x30
c0de05ca:	9304      	str	r3, [sp, #16]
c0de05cc:	460b      	mov	r3, r1
c0de05ce:	e7e3      	b.n	c0de0598 <mcu_usb_printf+0x54>
            switch(*format++)
c0de05d0:	2a67      	cmp	r2, #103	; 0x67
c0de05d2:	dd04      	ble.n	c0de05de <mcu_usb_printf+0x9a>
c0de05d4:	2a72      	cmp	r2, #114	; 0x72
c0de05d6:	dd1e      	ble.n	c0de0616 <mcu_usb_printf+0xd2>
c0de05d8:	2a73      	cmp	r2, #115	; 0x73
c0de05da:	d136      	bne.n	c0de064a <mcu_usb_printf+0x106>
c0de05dc:	e020      	b.n	c0de0620 <mcu_usb_printf+0xdc>
c0de05de:	2a62      	cmp	r2, #98	; 0x62
c0de05e0:	dc38      	bgt.n	c0de0654 <mcu_usb_printf+0x110>
c0de05e2:	2a48      	cmp	r2, #72	; 0x48
c0de05e4:	d173      	bne.n	c0de06ce <mcu_usb_printf+0x18a>
c0de05e6:	2001      	movs	r0, #1
c0de05e8:	e018      	b.n	c0de061c <mcu_usb_printf+0xd8>
c0de05ea:	2a25      	cmp	r2, #37	; 0x25
c0de05ec:	d07f      	beq.n	c0de06ee <mcu_usb_printf+0x1aa>
c0de05ee:	2a2a      	cmp	r2, #42	; 0x2a
c0de05f0:	d021      	beq.n	c0de0636 <mcu_usb_printf+0xf2>
c0de05f2:	2a2e      	cmp	r2, #46	; 0x2e
c0de05f4:	d000      	beq.n	c0de05f8 <mcu_usb_printf+0xb4>
c0de05f6:	e090      	b.n	c0de071a <mcu_usb_printf+0x1d6>
                // special %.*H or %.*h format to print a given length of hex digits (case: H UPPER, h lower)
                //
                case '.':
                {
                  // ensure next char is '*' and next one is 's'
                  if (format[0] == '*' && (format[1] == 's' || format[1] == 'H' || format[1] == 'h')) {
c0de05f8:	7821      	ldrb	r1, [r4, #0]
c0de05fa:	292a      	cmp	r1, #42	; 0x2a
c0de05fc:	d000      	beq.n	c0de0600 <mcu_usb_printf+0xbc>
c0de05fe:	e08c      	b.n	c0de071a <mcu_usb_printf+0x1d6>
c0de0600:	7861      	ldrb	r1, [r4, #1]
c0de0602:	2948      	cmp	r1, #72	; 0x48
c0de0604:	d004      	beq.n	c0de0610 <mcu_usb_printf+0xcc>
c0de0606:	2973      	cmp	r1, #115	; 0x73
c0de0608:	d002      	beq.n	c0de0610 <mcu_usb_printf+0xcc>
c0de060a:	2968      	cmp	r1, #104	; 0x68
c0de060c:	d000      	beq.n	c0de0610 <mcu_usb_printf+0xcc>
c0de060e:	e084      	b.n	c0de071a <mcu_usb_printf+0x1d6>
c0de0610:	1c64      	adds	r4, r4, #1
c0de0612:	2301      	movs	r3, #1
c0de0614:	e013      	b.n	c0de063e <mcu_usb_printf+0xfa>
            switch(*format++)
c0de0616:	2a68      	cmp	r2, #104	; 0x68
c0de0618:	d15e      	bne.n	c0de06d8 <mcu_usb_printf+0x194>
c0de061a:	2000      	movs	r0, #0
c0de061c:	9002      	str	r0, [sp, #8]
c0de061e:	2010      	movs	r0, #16
                case_s:
                {
                    //
                    // Get the string pointer from the varargs.
                    //
                    pcStr = va_arg(vaArgP, char *);
c0de0620:	9b06      	ldr	r3, [sp, #24]
c0de0622:	1d1a      	adds	r2, r3, #4
c0de0624:	9206      	str	r2, [sp, #24]

                    //
                    // Determine the length of the string. (if not specified using .*)
                    //
                    switch(cStrlenSet) {
c0de0626:	b2ca      	uxtb	r2, r1
                    pcStr = va_arg(vaArgP, char *);
c0de0628:	681f      	ldr	r7, [r3, #0]
                    switch(cStrlenSet) {
c0de062a:	2a01      	cmp	r2, #1
c0de062c:	dd20      	ble.n	c0de0670 <mcu_usb_printf+0x12c>
c0de062e:	2a02      	cmp	r2, #2
c0de0630:	460b      	mov	r3, r1
c0de0632:	d1b1      	bne.n	c0de0598 <mcu_usb_printf+0x54>
c0de0634:	e06e      	b.n	c0de0714 <mcu_usb_printf+0x1d0>
                  if (*format == 's' ) {
c0de0636:	7821      	ldrb	r1, [r4, #0]
c0de0638:	2973      	cmp	r1, #115	; 0x73
c0de063a:	d16e      	bne.n	c0de071a <mcu_usb_printf+0x1d6>
c0de063c:	2302      	movs	r3, #2
c0de063e:	9906      	ldr	r1, [sp, #24]
c0de0640:	1d0a      	adds	r2, r1, #4
c0de0642:	9206      	str	r2, [sp, #24]
c0de0644:	6809      	ldr	r1, [r1, #0]
            switch(*format++)
c0de0646:	9105      	str	r1, [sp, #20]
c0de0648:	e7a6      	b.n	c0de0598 <mcu_usb_printf+0x54>
c0de064a:	2a75      	cmp	r2, #117	; 0x75
c0de064c:	d051      	beq.n	c0de06f2 <mcu_usb_printf+0x1ae>
c0de064e:	2a78      	cmp	r2, #120	; 0x78
c0de0650:	d044      	beq.n	c0de06dc <mcu_usb_printf+0x198>
c0de0652:	e062      	b.n	c0de071a <mcu_usb_printf+0x1d6>
c0de0654:	2a63      	cmp	r2, #99	; 0x63
c0de0656:	d055      	beq.n	c0de0704 <mcu_usb_printf+0x1c0>
c0de0658:	2a64      	cmp	r2, #100	; 0x64
c0de065a:	d15e      	bne.n	c0de071a <mcu_usb_printf+0x1d6>
                    ulValue = va_arg(vaArgP, unsigned long);
c0de065c:	9806      	ldr	r0, [sp, #24]
c0de065e:	1d01      	adds	r1, r0, #4
c0de0660:	9106      	str	r1, [sp, #24]
c0de0662:	6805      	ldr	r5, [r0, #0]
c0de0664:	950b      	str	r5, [sp, #44]	; 0x2c
c0de0666:	200a      	movs	r0, #10
                    if((long)ulValue < 0)
c0de0668:	2d00      	cmp	r5, #0
c0de066a:	d45f      	bmi.n	c0de072c <mcu_usb_printf+0x1e8>
c0de066c:	2100      	movs	r1, #0
c0de066e:	e060      	b.n	c0de0732 <mcu_usb_printf+0x1ee>
                    switch(cStrlenSet) {
c0de0670:	2a00      	cmp	r2, #0
c0de0672:	9b02      	ldr	r3, [sp, #8]
c0de0674:	9d05      	ldr	r5, [sp, #20]
c0de0676:	d105      	bne.n	c0de0684 <mcu_usb_printf+0x140>
c0de0678:	2100      	movs	r1, #0
                      // compute length with strlen
                      case 0:
                        for(ulIdx = 0; pcStr[ulIdx] != '\0'; ulIdx++)
c0de067a:	5c7a      	ldrb	r2, [r7, r1]
c0de067c:	1c49      	adds	r1, r1, #1
c0de067e:	2a00      	cmp	r2, #0
c0de0680:	d1fb      	bne.n	c0de067a <mcu_usb_printf+0x136>
                    }

                    //
                    // Write the string.
                    //
                    switch(ulBase) {
c0de0682:	1e4d      	subs	r5, r1, #1
c0de0684:	2810      	cmp	r0, #16
c0de0686:	d14c      	bne.n	c0de0722 <mcu_usb_printf+0x1de>
                      default:
                        mcu_usb_prints(pcStr, ulIdx);
                        break;
                      case 16: {
                        unsigned char nibble1, nibble2;
                        for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0de0688:	2d00      	cmp	r5, #0
c0de068a:	d100      	bne.n	c0de068e <mcu_usb_printf+0x14a>
c0de068c:	e765      	b.n	c0de055a <mcu_usb_printf+0x16>
                          nibble1 = (pcStr[ulCount]>>4)&0xF;
c0de068e:	7838      	ldrb	r0, [r7, #0]
                          nibble2 = pcStr[ulCount]&0xF;
                          switch(ulCap) {
c0de0690:	2b00      	cmp	r3, #0
c0de0692:	d005      	beq.n	c0de06a0 <mcu_usb_printf+0x15c>
c0de0694:	2b01      	cmp	r3, #1
c0de0696:	d116      	bne.n	c0de06c6 <mcu_usb_printf+0x182>
c0de0698:	9505      	str	r5, [sp, #20]
c0de069a:	496a      	ldr	r1, [pc, #424]	; (c0de0844 <mcu_usb_printf+0x300>)
c0de069c:	4479      	add	r1, pc
c0de069e:	e002      	b.n	c0de06a6 <mcu_usb_printf+0x162>
c0de06a0:	9505      	str	r5, [sp, #20]
c0de06a2:	4966      	ldr	r1, [pc, #408]	; (c0de083c <mcu_usb_printf+0x2f8>)
c0de06a4:	4479      	add	r1, pc
c0de06a6:	9104      	str	r1, [sp, #16]
c0de06a8:	260f      	movs	r6, #15
c0de06aa:	4006      	ands	r6, r0
c0de06ac:	0900      	lsrs	r0, r0, #4
c0de06ae:	1808      	adds	r0, r1, r0
c0de06b0:	2501      	movs	r5, #1
c0de06b2:	4629      	mov	r1, r5
c0de06b4:	f7ff ff32 	bl	c0de051c <mcu_usb_prints>
c0de06b8:	9804      	ldr	r0, [sp, #16]
c0de06ba:	1980      	adds	r0, r0, r6
c0de06bc:	4629      	mov	r1, r5
c0de06be:	f7ff ff2d 	bl	c0de051c <mcu_usb_prints>
c0de06c2:	9b02      	ldr	r3, [sp, #8]
c0de06c4:	9d05      	ldr	r5, [sp, #20]
                        for (ulCount = 0; ulCount < ulIdx; ulCount++) {
c0de06c6:	1c7f      	adds	r7, r7, #1
c0de06c8:	1e6d      	subs	r5, r5, #1
c0de06ca:	d1e0      	bne.n	c0de068e <mcu_usb_printf+0x14a>
c0de06cc:	e745      	b.n	c0de055a <mcu_usb_printf+0x16>
            switch(*format++)
c0de06ce:	2a58      	cmp	r2, #88	; 0x58
c0de06d0:	d123      	bne.n	c0de071a <mcu_usb_printf+0x1d6>
c0de06d2:	2001      	movs	r0, #1
c0de06d4:	9002      	str	r0, [sp, #8]
c0de06d6:	e001      	b.n	c0de06dc <mcu_usb_printf+0x198>
c0de06d8:	2a70      	cmp	r2, #112	; 0x70
c0de06da:	d11e      	bne.n	c0de071a <mcu_usb_printf+0x1d6>
                case 'p':
                {
                    //
                    // Get the value from the varargs.
                    //
                    ulValue = va_arg(vaArgP, unsigned long);
c0de06dc:	9806      	ldr	r0, [sp, #24]
c0de06de:	1d01      	adds	r1, r0, #4
c0de06e0:	9106      	str	r1, [sp, #24]
c0de06e2:	6805      	ldr	r5, [r0, #0]
c0de06e4:	950b      	str	r5, [sp, #44]	; 0x2c
c0de06e6:	2000      	movs	r0, #0
c0de06e8:	9001      	str	r0, [sp, #4]
c0de06ea:	2010      	movs	r0, #16
c0de06ec:	e022      	b.n	c0de0734 <mcu_usb_printf+0x1f0>
                case '%':
                {
                    //
                    // Simply write a single %.
                    //
                    mcu_usb_prints(format - 1, 1);
c0de06ee:	1e60      	subs	r0, r4, #1
c0de06f0:	e00e      	b.n	c0de0710 <mcu_usb_printf+0x1cc>
                    ulValue = va_arg(vaArgP, unsigned long);
c0de06f2:	9806      	ldr	r0, [sp, #24]
c0de06f4:	1d01      	adds	r1, r0, #4
c0de06f6:	9106      	str	r1, [sp, #24]
c0de06f8:	6805      	ldr	r5, [r0, #0]
c0de06fa:	950b      	str	r5, [sp, #44]	; 0x2c
c0de06fc:	2000      	movs	r0, #0
c0de06fe:	9001      	str	r0, [sp, #4]
c0de0700:	200a      	movs	r0, #10
c0de0702:	e017      	b.n	c0de0734 <mcu_usb_printf+0x1f0>
                    ulValue = va_arg(vaArgP, unsigned long);
c0de0704:	9806      	ldr	r0, [sp, #24]
c0de0706:	1d01      	adds	r1, r0, #4
c0de0708:	9106      	str	r1, [sp, #24]
c0de070a:	6800      	ldr	r0, [r0, #0]
c0de070c:	900b      	str	r0, [sp, #44]	; 0x2c
c0de070e:	a80b      	add	r0, sp, #44	; 0x2c
c0de0710:	2101      	movs	r1, #1
c0de0712:	e071      	b.n	c0de07f8 <mcu_usb_printf+0x2b4>
                        if (pcStr[0] == '\0') {
c0de0714:	7838      	ldrb	r0, [r7, #0]
c0de0716:	2800      	cmp	r0, #0
c0de0718:	d071      	beq.n	c0de07fe <mcu_usb_printf+0x2ba>
                default:
                {
                    //
                    // Indicate an error.
                    //
                    mcu_usb_prints("ERROR", 5);
c0de071a:	4847      	ldr	r0, [pc, #284]	; (c0de0838 <mcu_usb_printf+0x2f4>)
c0de071c:	4478      	add	r0, pc
c0de071e:	2105      	movs	r1, #5
c0de0720:	e06a      	b.n	c0de07f8 <mcu_usb_printf+0x2b4>
                        mcu_usb_prints(pcStr, ulIdx);
c0de0722:	4638      	mov	r0, r7
c0de0724:	4629      	mov	r1, r5
c0de0726:	f7ff fef9 	bl	c0de051c <mcu_usb_prints>
c0de072a:	e071      	b.n	c0de0810 <mcu_usb_printf+0x2cc>
                        ulValue = -(long)ulValue;
c0de072c:	426d      	negs	r5, r5
c0de072e:	950b      	str	r5, [sp, #44]	; 0x2c
c0de0730:	2101      	movs	r1, #1
c0de0732:	9101      	str	r1, [sp, #4]
                        (((ulIdx * ulBase) <= ulValue) &&
c0de0734:	42a8      	cmp	r0, r5
c0de0736:	9003      	str	r0, [sp, #12]
c0de0738:	d901      	bls.n	c0de073e <mcu_usb_printf+0x1fa>
c0de073a:	2701      	movs	r7, #1
c0de073c:	e00f      	b.n	c0de075e <mcu_usb_printf+0x21a>
                    for(ulIdx = 1;
c0de073e:	1e72      	subs	r2, r6, #1
c0de0740:	4607      	mov	r7, r0
c0de0742:	4616      	mov	r6, r2
c0de0744:	2100      	movs	r1, #0
                        (((ulIdx * ulBase) <= ulValue) &&
c0de0746:	9803      	ldr	r0, [sp, #12]
c0de0748:	463a      	mov	r2, r7
c0de074a:	460b      	mov	r3, r1
c0de074c:	f000 f994 	bl	c0de0a78 <__aeabi_lmul>
c0de0750:	1e4a      	subs	r2, r1, #1
c0de0752:	4191      	sbcs	r1, r2
c0de0754:	42a8      	cmp	r0, r5
c0de0756:	d802      	bhi.n	c0de075e <mcu_usb_printf+0x21a>
                    for(ulIdx = 1;
c0de0758:	1e72      	subs	r2, r6, #1
c0de075a:	2900      	cmp	r1, #0
c0de075c:	d0f0      	beq.n	c0de0740 <mcu_usb_printf+0x1fc>
c0de075e:	9801      	ldr	r0, [sp, #4]
                    if(ulNeg)
c0de0760:	2800      	cmp	r0, #0
c0de0762:	9505      	str	r5, [sp, #20]
c0de0764:	d000      	beq.n	c0de0768 <mcu_usb_printf+0x224>
c0de0766:	1e76      	subs	r6, r6, #1
c0de0768:	9a04      	ldr	r2, [sp, #16]
c0de076a:	2500      	movs	r5, #0
                    if(ulNeg && (cFill == '0'))
c0de076c:	2800      	cmp	r0, #0
c0de076e:	d009      	beq.n	c0de0784 <mcu_usb_printf+0x240>
c0de0770:	b2d0      	uxtb	r0, r2
c0de0772:	2830      	cmp	r0, #48	; 0x30
c0de0774:	d108      	bne.n	c0de0788 <mcu_usb_printf+0x244>
c0de0776:	a807      	add	r0, sp, #28
c0de0778:	212d      	movs	r1, #45	; 0x2d
                        pcBuf[ulPos++] = '-';
c0de077a:	7001      	strb	r1, [r0, #0]
c0de077c:	2001      	movs	r0, #1
c0de077e:	4629      	mov	r1, r5
c0de0780:	4605      	mov	r5, r0
c0de0782:	e002      	b.n	c0de078a <mcu_usb_printf+0x246>
c0de0784:	4629      	mov	r1, r5
c0de0786:	e000      	b.n	c0de078a <mcu_usb_printf+0x246>
c0de0788:	2101      	movs	r1, #1
                    if((ulCount > 1) && (ulCount < 16))
c0de078a:	1eb0      	subs	r0, r6, #2
c0de078c:	280d      	cmp	r0, #13
c0de078e:	d80c      	bhi.n	c0de07aa <mcu_usb_printf+0x266>
c0de0790:	a807      	add	r0, sp, #28
                        for(ulCount--; ulCount; ulCount--)
c0de0792:	1940      	adds	r0, r0, r5
c0de0794:	1e76      	subs	r6, r6, #1
                            pcBuf[ulPos++] = cFill;
c0de0796:	b2d2      	uxtb	r2, r2
c0de0798:	9104      	str	r1, [sp, #16]
c0de079a:	4631      	mov	r1, r6
c0de079c:	f000 f9a4 	bl	c0de0ae8 <__aeabi_memset>
c0de07a0:	9904      	ldr	r1, [sp, #16]
c0de07a2:	1e76      	subs	r6, r6, #1
c0de07a4:	1c6d      	adds	r5, r5, #1
                        for(ulCount--; ulCount; ulCount--)
c0de07a6:	2e00      	cmp	r6, #0
c0de07a8:	d1fb      	bne.n	c0de07a2 <mcu_usb_printf+0x25e>
                    if(ulNeg)
c0de07aa:	2900      	cmp	r1, #0
c0de07ac:	d003      	beq.n	c0de07b6 <mcu_usb_printf+0x272>
c0de07ae:	a807      	add	r0, sp, #28
c0de07b0:	212d      	movs	r1, #45	; 0x2d
                        pcBuf[ulPos++] = '-';
c0de07b2:	5541      	strb	r1, [r0, r5]
c0de07b4:	1c6d      	adds	r5, r5, #1
                    for(; ulIdx; ulIdx /= ulBase)
c0de07b6:	2f00      	cmp	r7, #0
c0de07b8:	d01c      	beq.n	c0de07f4 <mcu_usb_printf+0x2b0>
c0de07ba:	9802      	ldr	r0, [sp, #8]
c0de07bc:	2800      	cmp	r0, #0
c0de07be:	d002      	beq.n	c0de07c6 <mcu_usb_printf+0x282>
c0de07c0:	4823      	ldr	r0, [pc, #140]	; (c0de0850 <mcu_usb_printf+0x30c>)
c0de07c2:	4478      	add	r0, pc
c0de07c4:	e001      	b.n	c0de07ca <mcu_usb_printf+0x286>
c0de07c6:	4821      	ldr	r0, [pc, #132]	; (c0de084c <mcu_usb_printf+0x308>)
c0de07c8:	4478      	add	r0, pc
c0de07ca:	9004      	str	r0, [sp, #16]
c0de07cc:	9e03      	ldr	r6, [sp, #12]
c0de07ce:	9805      	ldr	r0, [sp, #20]
c0de07d0:	4639      	mov	r1, r7
c0de07d2:	f000 f8c5 	bl	c0de0960 <__udivsi3>
c0de07d6:	4631      	mov	r1, r6
c0de07d8:	f000 f948 	bl	c0de0a6c <__aeabi_uidivmod>
c0de07dc:	9804      	ldr	r0, [sp, #16]
c0de07de:	5c40      	ldrb	r0, [r0, r1]
c0de07e0:	a907      	add	r1, sp, #28
                          pcBuf[ulPos++] = g_pcHex[(ulValue / ulIdx) % ulBase];
c0de07e2:	5548      	strb	r0, [r1, r5]
                    for(; ulIdx; ulIdx /= ulBase)
c0de07e4:	4638      	mov	r0, r7
c0de07e6:	4631      	mov	r1, r6
c0de07e8:	f000 f8ba 	bl	c0de0960 <__udivsi3>
c0de07ec:	1c6d      	adds	r5, r5, #1
c0de07ee:	42be      	cmp	r6, r7
c0de07f0:	4607      	mov	r7, r0
c0de07f2:	d9ec      	bls.n	c0de07ce <mcu_usb_printf+0x28a>
c0de07f4:	a807      	add	r0, sp, #28
                    mcu_usb_prints(pcBuf, ulPos);
c0de07f6:	4629      	mov	r1, r5
c0de07f8:	f7ff fe90 	bl	c0de051c <mcu_usb_prints>
c0de07fc:	e6ad      	b.n	c0de055a <mcu_usb_printf+0x16>
                          do {
c0de07fe:	9805      	ldr	r0, [sp, #20]
c0de0800:	1c47      	adds	r7, r0, #1
                            mcu_usb_prints(" ", 1);
c0de0802:	480f      	ldr	r0, [pc, #60]	; (c0de0840 <mcu_usb_printf+0x2fc>)
c0de0804:	4478      	add	r0, pc
c0de0806:	2101      	movs	r1, #1
c0de0808:	f7ff fe88 	bl	c0de051c <mcu_usb_prints>
                          } while(ulStrlen-- > 0);
c0de080c:	1e7f      	subs	r7, r7, #1
c0de080e:	d1f8      	bne.n	c0de0802 <mcu_usb_printf+0x2be>
                    if(ulCount > ulIdx)
c0de0810:	42ae      	cmp	r6, r5
c0de0812:	d800      	bhi.n	c0de0816 <mcu_usb_printf+0x2d2>
c0de0814:	e6a1      	b.n	c0de055a <mcu_usb_printf+0x16>
                        ulCount -= ulIdx;
c0de0816:	1b70      	subs	r0, r6, r5
c0de0818:	d100      	bne.n	c0de081c <mcu_usb_printf+0x2d8>
c0de081a:	e69e      	b.n	c0de055a <mcu_usb_printf+0x16>
                        while(ulCount--)
c0de081c:	1bad      	subs	r5, r5, r6
                            mcu_usb_prints(" ", 1);
c0de081e:	480a      	ldr	r0, [pc, #40]	; (c0de0848 <mcu_usb_printf+0x304>)
c0de0820:	4478      	add	r0, pc
c0de0822:	2101      	movs	r1, #1
c0de0824:	f7ff fe7a 	bl	c0de051c <mcu_usb_prints>
                        while(ulCount--)
c0de0828:	1c6d      	adds	r5, r5, #1
c0de082a:	d3f8      	bcc.n	c0de081e <mcu_usb_printf+0x2da>
c0de082c:	e695      	b.n	c0de055a <mcu_usb_printf+0x16>

    //
    // End the varargs processing.
    //
    va_end(vaArgP);
}
c0de082e:	b00c      	add	sp, #48	; 0x30
c0de0830:	bcf0      	pop	{r4, r5, r6, r7}
c0de0832:	bc01      	pop	{r0}
c0de0834:	b003      	add	sp, #12
c0de0836:	4700      	bx	r0
c0de0838:	00000770 	.word	0x00000770
c0de083c:	0000086c 	.word	0x0000086c
c0de0840:	0000061b 	.word	0x0000061b
c0de0844:	00000884 	.word	0x00000884
c0de0848:	000005ff 	.word	0x000005ff
c0de084c:	00000748 	.word	0x00000748
c0de0850:	0000075e 	.word	0x0000075e

c0de0854 <pic_internal>:
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
__attribute__((naked)) void *pic_internal(void *link_address)
{
  // compute the delta offset between LinkMemAddr & ExecMemAddr
  __asm volatile ("mov r2, pc\n");
c0de0854:	467a      	mov	r2, pc
  __asm volatile ("ldr r1, =pic_internal\n");
c0de0856:	4902      	ldr	r1, [pc, #8]	; (c0de0860 <pic_internal+0xc>)
  __asm volatile ("adds r1, r1, #3\n");
c0de0858:	1cc9      	adds	r1, r1, #3
  __asm volatile ("subs r1, r1, r2\n");
c0de085a:	1a89      	subs	r1, r1, r2

  // adjust value of the given parameter
  __asm volatile ("subs r0, r0, r1\n");
c0de085c:	1a40      	subs	r0, r0, r1
  __asm volatile ("bx lr\n");
c0de085e:	4770      	bx	lr
c0de0860:	c0de0855 	.word	0xc0de0855

c0de0864 <pic>:
#elif defined(ST33)

extern void _bss;
extern void _estack;

void *pic(void *link_address) {
c0de0864:	b580      	push	{r7, lr}
  void *n, *en;

  // check if in the LINKED TEXT zone
  __asm volatile("ldr %0, =_nvram":"=r"(n));
c0de0866:	4a09      	ldr	r2, [pc, #36]	; (c0de088c <pic+0x28>)
  __asm volatile("ldr %0, =_envram":"=r"(en));
c0de0868:	4909      	ldr	r1, [pc, #36]	; (c0de0890 <pic+0x2c>)
  if (link_address >= n && link_address <= en) {
c0de086a:	4282      	cmp	r2, r0
c0de086c:	d803      	bhi.n	c0de0876 <pic+0x12>
c0de086e:	4281      	cmp	r1, r0
c0de0870:	d301      	bcc.n	c0de0876 <pic+0x12>
    link_address = pic_internal(link_address);
c0de0872:	f7ff ffef 	bl	c0de0854 <pic_internal>
  }

  // check if in the LINKED RAM zone
  __asm volatile("ldr %0, =_bss":"=r"(n));
c0de0876:	4907      	ldr	r1, [pc, #28]	; (c0de0894 <pic+0x30>)
  __asm volatile("ldr %0, =_estack":"=r"(en));
c0de0878:	4a07      	ldr	r2, [pc, #28]	; (c0de0898 <pic+0x34>)
  if (link_address >= n && link_address <= en) {
c0de087a:	4288      	cmp	r0, r1
c0de087c:	d304      	bcc.n	c0de0888 <pic+0x24>
c0de087e:	4290      	cmp	r0, r2
c0de0880:	d802      	bhi.n	c0de0888 <pic+0x24>
    __asm volatile("mov %0, r9":"=r"(en));
    // deref into the RAM therefore add the RAM offset from R9
    link_address = (char *)link_address - (char *)n + (char *)en;
c0de0882:	1a40      	subs	r0, r0, r1
    __asm volatile("mov %0, r9":"=r"(en));
c0de0884:	4649      	mov	r1, r9
    link_address = (char *)link_address - (char *)n + (char *)en;
c0de0886:	1808      	adds	r0, r1, r0
  }

  return link_address;
c0de0888:	bd80      	pop	{r7, pc}
c0de088a:	46c0      	nop			; (mov r8, r8)
c0de088c:	c0de0000 	.word	0xc0de0000
c0de0890:	c0de1000 	.word	0xc0de1000
c0de0894:	da7a0000 	.word	0xda7a0000
c0de0898:	da7a7800 	.word	0xda7a7800

c0de089c <SVC_Call>:
.thumb
.thumb_func
.global SVC_Call

SVC_Call:
    svc 1
c0de089c:	df01      	svc	1
    cmp r1, #0
c0de089e:	2900      	cmp	r1, #0
    bne exception
c0de08a0:	d100      	bne.n	c0de08a4 <exception>
    bx lr
c0de08a2:	4770      	bx	lr

c0de08a4 <exception>:
exception:
    // THROW(ex);
    mov r0, r1
c0de08a4:	4608      	mov	r0, r1
    bl os_longjmp
c0de08a6:	f7ff fe2b 	bl	c0de0500 <os_longjmp>
c0de08aa:	d4d4      	bmi.n	c0de0856 <pic_internal+0x2>

c0de08ac <get_api_level>:
#include <string.h>

unsigned int SVC_Call(unsigned int syscall_id, void *parameters);
unsigned int SVC_cx_call(unsigned int syscall_id, unsigned int * parameters);

unsigned int get_api_level(void) {
c0de08ac:	b580      	push	{r7, lr}
c0de08ae:	b084      	sub	sp, #16
c0de08b0:	2000      	movs	r0, #0
  unsigned int parameters [2+1];
  parameters[0] = 0;
  parameters[1] = 0;
c0de08b2:	9002      	str	r0, [sp, #8]
  parameters[0] = 0;
c0de08b4:	9001      	str	r0, [sp, #4]
c0de08b6:	4803      	ldr	r0, [pc, #12]	; (c0de08c4 <get_api_level+0x18>)
c0de08b8:	a901      	add	r1, sp, #4
  return SVC_Call(SYSCALL_get_api_level_ID_IN, parameters);
c0de08ba:	f7ff ffef 	bl	c0de089c <SVC_Call>
c0de08be:	b004      	add	sp, #16
c0de08c0:	bd80      	pop	{r7, pc}
c0de08c2:	46c0      	nop			; (mov r8, r8)
c0de08c4:	60000138 	.word	0x60000138

c0de08c8 <os_lib_call>:
  SVC_Call(SYSCALL_os_ux_result_ID_IN, parameters);
  return;
}
#endif // !defined(APP_UX)

void os_lib_call ( unsigned int * call_parameters ) {
c0de08c8:	b580      	push	{r7, lr}
c0de08ca:	b084      	sub	sp, #16
c0de08cc:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)call_parameters;
  parameters[1] = 0;
c0de08ce:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)call_parameters;
c0de08d0:	9001      	str	r0, [sp, #4]
c0de08d2:	4803      	ldr	r0, [pc, #12]	; (c0de08e0 <os_lib_call+0x18>)
c0de08d4:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_lib_call_ID_IN, parameters);
c0de08d6:	f7ff ffe1 	bl	c0de089c <SVC_Call>
  return;
}
c0de08da:	b004      	add	sp, #16
c0de08dc:	bd80      	pop	{r7, pc}
c0de08de:	46c0      	nop			; (mov r8, r8)
c0de08e0:	6000670d 	.word	0x6000670d

c0de08e4 <os_lib_end>:

void os_lib_end ( void ) {
c0de08e4:	b580      	push	{r7, lr}
c0de08e6:	b082      	sub	sp, #8
c0de08e8:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0de08ea:	9001      	str	r0, [sp, #4]
c0de08ec:	4802      	ldr	r0, [pc, #8]	; (c0de08f8 <os_lib_end+0x14>)
c0de08ee:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_os_lib_end_ID_IN, parameters);
c0de08f0:	f7ff ffd4 	bl	c0de089c <SVC_Call>
  return;
}
c0de08f4:	b002      	add	sp, #8
c0de08f6:	bd80      	pop	{r7, pc}
c0de08f8:	6000688d 	.word	0x6000688d

c0de08fc <os_sched_exit>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_exec_ID_IN, parameters);
  return;
}

void __attribute__((noreturn)) os_sched_exit ( bolos_task_status_t exit_code ) {
c0de08fc:	b084      	sub	sp, #16
c0de08fe:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)exit_code;
  parameters[1] = 0;
c0de0900:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)exit_code;
c0de0902:	9001      	str	r0, [sp, #4]
c0de0904:	4802      	ldr	r0, [pc, #8]	; (c0de0910 <os_sched_exit+0x14>)
c0de0906:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
c0de0908:	f7ff ffc8 	bl	c0de089c <SVC_Call>

  // The os_sched_exit syscall should never return. Just in case, prevent the
  // device from freezing (because of the following infinite loop) thanks to an
  // undefined instruction.
  asm volatile ("udf #255");
c0de090c:	deff      	udf	#255	; 0xff

  // remove the warning caused by -Winvalid-noreturn
  while (1) {
c0de090e:	e7fe      	b.n	c0de090e <os_sched_exit+0x12>
c0de0910:	60009abe 	.word	0x60009abe

c0de0914 <io_seph_send>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_kill_ID_IN, parameters);
  return;
}

void io_seph_send ( const unsigned char * buffer, unsigned short length ) {
c0de0914:	b580      	push	{r7, lr}
c0de0916:	b084      	sub	sp, #16
  unsigned int parameters [2+2];
  parameters[0] = (unsigned int)buffer;
  parameters[1] = (unsigned int)length;
c0de0918:	9101      	str	r1, [sp, #4]
  parameters[0] = (unsigned int)buffer;
c0de091a:	9000      	str	r0, [sp, #0]
c0de091c:	4802      	ldr	r0, [pc, #8]	; (c0de0928 <io_seph_send+0x14>)
c0de091e:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_io_seph_send_ID_IN, parameters);
c0de0920:	f7ff ffbc 	bl	c0de089c <SVC_Call>
  return;
}
c0de0924:	b004      	add	sp, #16
c0de0926:	bd80      	pop	{r7, pc}
c0de0928:	60008381 	.word	0x60008381

c0de092c <try_context_get>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_nvm_erase_page_ID_IN, parameters);
  return;
}

try_context_t * try_context_get ( void ) {
c0de092c:	b580      	push	{r7, lr}
c0de092e:	b082      	sub	sp, #8
c0de0930:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0de0932:	9001      	str	r0, [sp, #4]
c0de0934:	4802      	ldr	r0, [pc, #8]	; (c0de0940 <try_context_get+0x14>)
c0de0936:	4669      	mov	r1, sp
  return (try_context_t *) SVC_Call(SYSCALL_try_context_get_ID_IN, parameters);
c0de0938:	f7ff ffb0 	bl	c0de089c <SVC_Call>
c0de093c:	b002      	add	sp, #8
c0de093e:	bd80      	pop	{r7, pc}
c0de0940:	600087b1 	.word	0x600087b1

c0de0944 <try_context_set>:
}

try_context_t * try_context_set ( try_context_t *context ) {
c0de0944:	b580      	push	{r7, lr}
c0de0946:	b084      	sub	sp, #16
c0de0948:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)context;
  parameters[1] = 0;
c0de094a:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)context;
c0de094c:	9001      	str	r0, [sp, #4]
c0de094e:	4803      	ldr	r0, [pc, #12]	; (c0de095c <try_context_set+0x18>)
c0de0950:	a901      	add	r1, sp, #4
  return (try_context_t *) SVC_Call(SYSCALL_try_context_set_ID_IN, parameters);
c0de0952:	f7ff ffa3 	bl	c0de089c <SVC_Call>
c0de0956:	b004      	add	sp, #16
c0de0958:	bd80      	pop	{r7, pc}
c0de095a:	46c0      	nop			; (mov r8, r8)
c0de095c:	60010b06 	.word	0x60010b06

c0de0960 <__udivsi3>:
c0de0960:	2200      	movs	r2, #0
c0de0962:	0843      	lsrs	r3, r0, #1
c0de0964:	428b      	cmp	r3, r1
c0de0966:	d374      	bcc.n	c0de0a52 <__udivsi3+0xf2>
c0de0968:	0903      	lsrs	r3, r0, #4
c0de096a:	428b      	cmp	r3, r1
c0de096c:	d35f      	bcc.n	c0de0a2e <__udivsi3+0xce>
c0de096e:	0a03      	lsrs	r3, r0, #8
c0de0970:	428b      	cmp	r3, r1
c0de0972:	d344      	bcc.n	c0de09fe <__udivsi3+0x9e>
c0de0974:	0b03      	lsrs	r3, r0, #12
c0de0976:	428b      	cmp	r3, r1
c0de0978:	d328      	bcc.n	c0de09cc <__udivsi3+0x6c>
c0de097a:	0c03      	lsrs	r3, r0, #16
c0de097c:	428b      	cmp	r3, r1
c0de097e:	d30d      	bcc.n	c0de099c <__udivsi3+0x3c>
c0de0980:	22ff      	movs	r2, #255	; 0xff
c0de0982:	0209      	lsls	r1, r1, #8
c0de0984:	ba12      	rev	r2, r2
c0de0986:	0c03      	lsrs	r3, r0, #16
c0de0988:	428b      	cmp	r3, r1
c0de098a:	d302      	bcc.n	c0de0992 <__udivsi3+0x32>
c0de098c:	1212      	asrs	r2, r2, #8
c0de098e:	0209      	lsls	r1, r1, #8
c0de0990:	d065      	beq.n	c0de0a5e <__udivsi3+0xfe>
c0de0992:	0b03      	lsrs	r3, r0, #12
c0de0994:	428b      	cmp	r3, r1
c0de0996:	d319      	bcc.n	c0de09cc <__udivsi3+0x6c>
c0de0998:	e000      	b.n	c0de099c <__udivsi3+0x3c>
c0de099a:	0a09      	lsrs	r1, r1, #8
c0de099c:	0bc3      	lsrs	r3, r0, #15
c0de099e:	428b      	cmp	r3, r1
c0de09a0:	d301      	bcc.n	c0de09a6 <__udivsi3+0x46>
c0de09a2:	03cb      	lsls	r3, r1, #15
c0de09a4:	1ac0      	subs	r0, r0, r3
c0de09a6:	4152      	adcs	r2, r2
c0de09a8:	0b83      	lsrs	r3, r0, #14
c0de09aa:	428b      	cmp	r3, r1
c0de09ac:	d301      	bcc.n	c0de09b2 <__udivsi3+0x52>
c0de09ae:	038b      	lsls	r3, r1, #14
c0de09b0:	1ac0      	subs	r0, r0, r3
c0de09b2:	4152      	adcs	r2, r2
c0de09b4:	0b43      	lsrs	r3, r0, #13
c0de09b6:	428b      	cmp	r3, r1
c0de09b8:	d301      	bcc.n	c0de09be <__udivsi3+0x5e>
c0de09ba:	034b      	lsls	r3, r1, #13
c0de09bc:	1ac0      	subs	r0, r0, r3
c0de09be:	4152      	adcs	r2, r2
c0de09c0:	0b03      	lsrs	r3, r0, #12
c0de09c2:	428b      	cmp	r3, r1
c0de09c4:	d301      	bcc.n	c0de09ca <__udivsi3+0x6a>
c0de09c6:	030b      	lsls	r3, r1, #12
c0de09c8:	1ac0      	subs	r0, r0, r3
c0de09ca:	4152      	adcs	r2, r2
c0de09cc:	0ac3      	lsrs	r3, r0, #11
c0de09ce:	428b      	cmp	r3, r1
c0de09d0:	d301      	bcc.n	c0de09d6 <__udivsi3+0x76>
c0de09d2:	02cb      	lsls	r3, r1, #11
c0de09d4:	1ac0      	subs	r0, r0, r3
c0de09d6:	4152      	adcs	r2, r2
c0de09d8:	0a83      	lsrs	r3, r0, #10
c0de09da:	428b      	cmp	r3, r1
c0de09dc:	d301      	bcc.n	c0de09e2 <__udivsi3+0x82>
c0de09de:	028b      	lsls	r3, r1, #10
c0de09e0:	1ac0      	subs	r0, r0, r3
c0de09e2:	4152      	adcs	r2, r2
c0de09e4:	0a43      	lsrs	r3, r0, #9
c0de09e6:	428b      	cmp	r3, r1
c0de09e8:	d301      	bcc.n	c0de09ee <__udivsi3+0x8e>
c0de09ea:	024b      	lsls	r3, r1, #9
c0de09ec:	1ac0      	subs	r0, r0, r3
c0de09ee:	4152      	adcs	r2, r2
c0de09f0:	0a03      	lsrs	r3, r0, #8
c0de09f2:	428b      	cmp	r3, r1
c0de09f4:	d301      	bcc.n	c0de09fa <__udivsi3+0x9a>
c0de09f6:	020b      	lsls	r3, r1, #8
c0de09f8:	1ac0      	subs	r0, r0, r3
c0de09fa:	4152      	adcs	r2, r2
c0de09fc:	d2cd      	bcs.n	c0de099a <__udivsi3+0x3a>
c0de09fe:	09c3      	lsrs	r3, r0, #7
c0de0a00:	428b      	cmp	r3, r1
c0de0a02:	d301      	bcc.n	c0de0a08 <__udivsi3+0xa8>
c0de0a04:	01cb      	lsls	r3, r1, #7
c0de0a06:	1ac0      	subs	r0, r0, r3
c0de0a08:	4152      	adcs	r2, r2
c0de0a0a:	0983      	lsrs	r3, r0, #6
c0de0a0c:	428b      	cmp	r3, r1
c0de0a0e:	d301      	bcc.n	c0de0a14 <__udivsi3+0xb4>
c0de0a10:	018b      	lsls	r3, r1, #6
c0de0a12:	1ac0      	subs	r0, r0, r3
c0de0a14:	4152      	adcs	r2, r2
c0de0a16:	0943      	lsrs	r3, r0, #5
c0de0a18:	428b      	cmp	r3, r1
c0de0a1a:	d301      	bcc.n	c0de0a20 <__udivsi3+0xc0>
c0de0a1c:	014b      	lsls	r3, r1, #5
c0de0a1e:	1ac0      	subs	r0, r0, r3
c0de0a20:	4152      	adcs	r2, r2
c0de0a22:	0903      	lsrs	r3, r0, #4
c0de0a24:	428b      	cmp	r3, r1
c0de0a26:	d301      	bcc.n	c0de0a2c <__udivsi3+0xcc>
c0de0a28:	010b      	lsls	r3, r1, #4
c0de0a2a:	1ac0      	subs	r0, r0, r3
c0de0a2c:	4152      	adcs	r2, r2
c0de0a2e:	08c3      	lsrs	r3, r0, #3
c0de0a30:	428b      	cmp	r3, r1
c0de0a32:	d301      	bcc.n	c0de0a38 <__udivsi3+0xd8>
c0de0a34:	00cb      	lsls	r3, r1, #3
c0de0a36:	1ac0      	subs	r0, r0, r3
c0de0a38:	4152      	adcs	r2, r2
c0de0a3a:	0883      	lsrs	r3, r0, #2
c0de0a3c:	428b      	cmp	r3, r1
c0de0a3e:	d301      	bcc.n	c0de0a44 <__udivsi3+0xe4>
c0de0a40:	008b      	lsls	r3, r1, #2
c0de0a42:	1ac0      	subs	r0, r0, r3
c0de0a44:	4152      	adcs	r2, r2
c0de0a46:	0843      	lsrs	r3, r0, #1
c0de0a48:	428b      	cmp	r3, r1
c0de0a4a:	d301      	bcc.n	c0de0a50 <__udivsi3+0xf0>
c0de0a4c:	004b      	lsls	r3, r1, #1
c0de0a4e:	1ac0      	subs	r0, r0, r3
c0de0a50:	4152      	adcs	r2, r2
c0de0a52:	1a41      	subs	r1, r0, r1
c0de0a54:	d200      	bcs.n	c0de0a58 <__udivsi3+0xf8>
c0de0a56:	4601      	mov	r1, r0
c0de0a58:	4152      	adcs	r2, r2
c0de0a5a:	4610      	mov	r0, r2
c0de0a5c:	4770      	bx	lr
c0de0a5e:	e7ff      	b.n	c0de0a60 <__udivsi3+0x100>
c0de0a60:	b501      	push	{r0, lr}
c0de0a62:	2000      	movs	r0, #0
c0de0a64:	f000 f806 	bl	c0de0a74 <__aeabi_idiv0>
c0de0a68:	bd02      	pop	{r1, pc}
c0de0a6a:	46c0      	nop			; (mov r8, r8)

c0de0a6c <__aeabi_uidivmod>:
c0de0a6c:	2900      	cmp	r1, #0
c0de0a6e:	d0f7      	beq.n	c0de0a60 <__udivsi3+0x100>
c0de0a70:	e776      	b.n	c0de0960 <__udivsi3>
c0de0a72:	4770      	bx	lr

c0de0a74 <__aeabi_idiv0>:
c0de0a74:	4770      	bx	lr
c0de0a76:	46c0      	nop			; (mov r8, r8)

c0de0a78 <__aeabi_lmul>:
c0de0a78:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de0a7a:	46ce      	mov	lr, r9
c0de0a7c:	4647      	mov	r7, r8
c0de0a7e:	0415      	lsls	r5, r2, #16
c0de0a80:	0c2d      	lsrs	r5, r5, #16
c0de0a82:	002e      	movs	r6, r5
c0de0a84:	b580      	push	{r7, lr}
c0de0a86:	0407      	lsls	r7, r0, #16
c0de0a88:	0c14      	lsrs	r4, r2, #16
c0de0a8a:	0c3f      	lsrs	r7, r7, #16
c0de0a8c:	4699      	mov	r9, r3
c0de0a8e:	0c03      	lsrs	r3, r0, #16
c0de0a90:	437e      	muls	r6, r7
c0de0a92:	435d      	muls	r5, r3
c0de0a94:	4367      	muls	r7, r4
c0de0a96:	4363      	muls	r3, r4
c0de0a98:	197f      	adds	r7, r7, r5
c0de0a9a:	0c34      	lsrs	r4, r6, #16
c0de0a9c:	19e4      	adds	r4, r4, r7
c0de0a9e:	469c      	mov	ip, r3
c0de0aa0:	42a5      	cmp	r5, r4
c0de0aa2:	d903      	bls.n	c0de0aac <__aeabi_lmul+0x34>
c0de0aa4:	2380      	movs	r3, #128	; 0x80
c0de0aa6:	025b      	lsls	r3, r3, #9
c0de0aa8:	4698      	mov	r8, r3
c0de0aaa:	44c4      	add	ip, r8
c0de0aac:	464b      	mov	r3, r9
c0de0aae:	4343      	muls	r3, r0
c0de0ab0:	4351      	muls	r1, r2
c0de0ab2:	0c25      	lsrs	r5, r4, #16
c0de0ab4:	0436      	lsls	r6, r6, #16
c0de0ab6:	4465      	add	r5, ip
c0de0ab8:	0c36      	lsrs	r6, r6, #16
c0de0aba:	0424      	lsls	r4, r4, #16
c0de0abc:	19a4      	adds	r4, r4, r6
c0de0abe:	195b      	adds	r3, r3, r5
c0de0ac0:	1859      	adds	r1, r3, r1
c0de0ac2:	0020      	movs	r0, r4
c0de0ac4:	bc0c      	pop	{r2, r3}
c0de0ac6:	4690      	mov	r8, r2
c0de0ac8:	4699      	mov	r9, r3
c0de0aca:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0de0acc <__aeabi_memclr>:
c0de0acc:	b510      	push	{r4, lr}
c0de0ace:	2200      	movs	r2, #0
c0de0ad0:	f000 f80a 	bl	c0de0ae8 <__aeabi_memset>
c0de0ad4:	bd10      	pop	{r4, pc}
c0de0ad6:	46c0      	nop			; (mov r8, r8)

c0de0ad8 <__aeabi_memcpy>:
c0de0ad8:	b510      	push	{r4, lr}
c0de0ada:	f000 f80d 	bl	c0de0af8 <memcpy>
c0de0ade:	bd10      	pop	{r4, pc}

c0de0ae0 <__aeabi_memmove>:
c0de0ae0:	b510      	push	{r4, lr}
c0de0ae2:	f000 f85d 	bl	c0de0ba0 <memmove>
c0de0ae6:	bd10      	pop	{r4, pc}

c0de0ae8 <__aeabi_memset>:
c0de0ae8:	0013      	movs	r3, r2
c0de0aea:	b510      	push	{r4, lr}
c0de0aec:	000a      	movs	r2, r1
c0de0aee:	0019      	movs	r1, r3
c0de0af0:	f000 f8b4 	bl	c0de0c5c <memset>
c0de0af4:	bd10      	pop	{r4, pc}
c0de0af6:	46c0      	nop			; (mov r8, r8)

c0de0af8 <memcpy>:
c0de0af8:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de0afa:	46c6      	mov	lr, r8
c0de0afc:	b500      	push	{lr}
c0de0afe:	2a0f      	cmp	r2, #15
c0de0b00:	d943      	bls.n	c0de0b8a <memcpy+0x92>
c0de0b02:	000b      	movs	r3, r1
c0de0b04:	2603      	movs	r6, #3
c0de0b06:	4303      	orrs	r3, r0
c0de0b08:	401e      	ands	r6, r3
c0de0b0a:	000c      	movs	r4, r1
c0de0b0c:	0003      	movs	r3, r0
c0de0b0e:	2e00      	cmp	r6, #0
c0de0b10:	d140      	bne.n	c0de0b94 <memcpy+0x9c>
c0de0b12:	0015      	movs	r5, r2
c0de0b14:	3d10      	subs	r5, #16
c0de0b16:	092d      	lsrs	r5, r5, #4
c0de0b18:	46ac      	mov	ip, r5
c0de0b1a:	012d      	lsls	r5, r5, #4
c0de0b1c:	46a8      	mov	r8, r5
c0de0b1e:	4480      	add	r8, r0
c0de0b20:	e000      	b.n	c0de0b24 <memcpy+0x2c>
c0de0b22:	003b      	movs	r3, r7
c0de0b24:	6867      	ldr	r7, [r4, #4]
c0de0b26:	6825      	ldr	r5, [r4, #0]
c0de0b28:	605f      	str	r7, [r3, #4]
c0de0b2a:	68e7      	ldr	r7, [r4, #12]
c0de0b2c:	601d      	str	r5, [r3, #0]
c0de0b2e:	60df      	str	r7, [r3, #12]
c0de0b30:	001f      	movs	r7, r3
c0de0b32:	68a5      	ldr	r5, [r4, #8]
c0de0b34:	3710      	adds	r7, #16
c0de0b36:	609d      	str	r5, [r3, #8]
c0de0b38:	3410      	adds	r4, #16
c0de0b3a:	4543      	cmp	r3, r8
c0de0b3c:	d1f1      	bne.n	c0de0b22 <memcpy+0x2a>
c0de0b3e:	4665      	mov	r5, ip
c0de0b40:	230f      	movs	r3, #15
c0de0b42:	240c      	movs	r4, #12
c0de0b44:	3501      	adds	r5, #1
c0de0b46:	012d      	lsls	r5, r5, #4
c0de0b48:	1949      	adds	r1, r1, r5
c0de0b4a:	4013      	ands	r3, r2
c0de0b4c:	1945      	adds	r5, r0, r5
c0de0b4e:	4214      	tst	r4, r2
c0de0b50:	d023      	beq.n	c0de0b9a <memcpy+0xa2>
c0de0b52:	598c      	ldr	r4, [r1, r6]
c0de0b54:	51ac      	str	r4, [r5, r6]
c0de0b56:	3604      	adds	r6, #4
c0de0b58:	1b9c      	subs	r4, r3, r6
c0de0b5a:	2c03      	cmp	r4, #3
c0de0b5c:	d8f9      	bhi.n	c0de0b52 <memcpy+0x5a>
c0de0b5e:	2403      	movs	r4, #3
c0de0b60:	3b04      	subs	r3, #4
c0de0b62:	089b      	lsrs	r3, r3, #2
c0de0b64:	3301      	adds	r3, #1
c0de0b66:	009b      	lsls	r3, r3, #2
c0de0b68:	4022      	ands	r2, r4
c0de0b6a:	18ed      	adds	r5, r5, r3
c0de0b6c:	18c9      	adds	r1, r1, r3
c0de0b6e:	1e56      	subs	r6, r2, #1
c0de0b70:	2a00      	cmp	r2, #0
c0de0b72:	d007      	beq.n	c0de0b84 <memcpy+0x8c>
c0de0b74:	2300      	movs	r3, #0
c0de0b76:	e000      	b.n	c0de0b7a <memcpy+0x82>
c0de0b78:	0023      	movs	r3, r4
c0de0b7a:	5cca      	ldrb	r2, [r1, r3]
c0de0b7c:	1c5c      	adds	r4, r3, #1
c0de0b7e:	54ea      	strb	r2, [r5, r3]
c0de0b80:	429e      	cmp	r6, r3
c0de0b82:	d1f9      	bne.n	c0de0b78 <memcpy+0x80>
c0de0b84:	bc04      	pop	{r2}
c0de0b86:	4690      	mov	r8, r2
c0de0b88:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0de0b8a:	0005      	movs	r5, r0
c0de0b8c:	1e56      	subs	r6, r2, #1
c0de0b8e:	2a00      	cmp	r2, #0
c0de0b90:	d1f0      	bne.n	c0de0b74 <memcpy+0x7c>
c0de0b92:	e7f7      	b.n	c0de0b84 <memcpy+0x8c>
c0de0b94:	1e56      	subs	r6, r2, #1
c0de0b96:	0005      	movs	r5, r0
c0de0b98:	e7ec      	b.n	c0de0b74 <memcpy+0x7c>
c0de0b9a:	001a      	movs	r2, r3
c0de0b9c:	e7f6      	b.n	c0de0b8c <memcpy+0x94>
c0de0b9e:	46c0      	nop			; (mov r8, r8)

c0de0ba0 <memmove>:
c0de0ba0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de0ba2:	46c6      	mov	lr, r8
c0de0ba4:	b500      	push	{lr}
c0de0ba6:	4288      	cmp	r0, r1
c0de0ba8:	d90c      	bls.n	c0de0bc4 <memmove+0x24>
c0de0baa:	188b      	adds	r3, r1, r2
c0de0bac:	4298      	cmp	r0, r3
c0de0bae:	d209      	bcs.n	c0de0bc4 <memmove+0x24>
c0de0bb0:	1e53      	subs	r3, r2, #1
c0de0bb2:	2a00      	cmp	r2, #0
c0de0bb4:	d003      	beq.n	c0de0bbe <memmove+0x1e>
c0de0bb6:	5cca      	ldrb	r2, [r1, r3]
c0de0bb8:	54c2      	strb	r2, [r0, r3]
c0de0bba:	3b01      	subs	r3, #1
c0de0bbc:	d2fb      	bcs.n	c0de0bb6 <memmove+0x16>
c0de0bbe:	bc04      	pop	{r2}
c0de0bc0:	4690      	mov	r8, r2
c0de0bc2:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0de0bc4:	2a0f      	cmp	r2, #15
c0de0bc6:	d80c      	bhi.n	c0de0be2 <memmove+0x42>
c0de0bc8:	0005      	movs	r5, r0
c0de0bca:	1e56      	subs	r6, r2, #1
c0de0bcc:	2a00      	cmp	r2, #0
c0de0bce:	d0f6      	beq.n	c0de0bbe <memmove+0x1e>
c0de0bd0:	2300      	movs	r3, #0
c0de0bd2:	e000      	b.n	c0de0bd6 <memmove+0x36>
c0de0bd4:	0023      	movs	r3, r4
c0de0bd6:	5cca      	ldrb	r2, [r1, r3]
c0de0bd8:	1c5c      	adds	r4, r3, #1
c0de0bda:	54ea      	strb	r2, [r5, r3]
c0de0bdc:	429e      	cmp	r6, r3
c0de0bde:	d1f9      	bne.n	c0de0bd4 <memmove+0x34>
c0de0be0:	e7ed      	b.n	c0de0bbe <memmove+0x1e>
c0de0be2:	000b      	movs	r3, r1
c0de0be4:	2603      	movs	r6, #3
c0de0be6:	4303      	orrs	r3, r0
c0de0be8:	401e      	ands	r6, r3
c0de0bea:	000c      	movs	r4, r1
c0de0bec:	0003      	movs	r3, r0
c0de0bee:	2e00      	cmp	r6, #0
c0de0bf0:	d12e      	bne.n	c0de0c50 <memmove+0xb0>
c0de0bf2:	0015      	movs	r5, r2
c0de0bf4:	3d10      	subs	r5, #16
c0de0bf6:	092d      	lsrs	r5, r5, #4
c0de0bf8:	46ac      	mov	ip, r5
c0de0bfa:	012d      	lsls	r5, r5, #4
c0de0bfc:	46a8      	mov	r8, r5
c0de0bfe:	4480      	add	r8, r0
c0de0c00:	e000      	b.n	c0de0c04 <memmove+0x64>
c0de0c02:	002b      	movs	r3, r5
c0de0c04:	001d      	movs	r5, r3
c0de0c06:	6827      	ldr	r7, [r4, #0]
c0de0c08:	3510      	adds	r5, #16
c0de0c0a:	601f      	str	r7, [r3, #0]
c0de0c0c:	6867      	ldr	r7, [r4, #4]
c0de0c0e:	605f      	str	r7, [r3, #4]
c0de0c10:	68a7      	ldr	r7, [r4, #8]
c0de0c12:	609f      	str	r7, [r3, #8]
c0de0c14:	68e7      	ldr	r7, [r4, #12]
c0de0c16:	3410      	adds	r4, #16
c0de0c18:	60df      	str	r7, [r3, #12]
c0de0c1a:	4543      	cmp	r3, r8
c0de0c1c:	d1f1      	bne.n	c0de0c02 <memmove+0x62>
c0de0c1e:	4665      	mov	r5, ip
c0de0c20:	230f      	movs	r3, #15
c0de0c22:	240c      	movs	r4, #12
c0de0c24:	3501      	adds	r5, #1
c0de0c26:	012d      	lsls	r5, r5, #4
c0de0c28:	1949      	adds	r1, r1, r5
c0de0c2a:	4013      	ands	r3, r2
c0de0c2c:	1945      	adds	r5, r0, r5
c0de0c2e:	4214      	tst	r4, r2
c0de0c30:	d011      	beq.n	c0de0c56 <memmove+0xb6>
c0de0c32:	598c      	ldr	r4, [r1, r6]
c0de0c34:	51ac      	str	r4, [r5, r6]
c0de0c36:	3604      	adds	r6, #4
c0de0c38:	1b9c      	subs	r4, r3, r6
c0de0c3a:	2c03      	cmp	r4, #3
c0de0c3c:	d8f9      	bhi.n	c0de0c32 <memmove+0x92>
c0de0c3e:	2403      	movs	r4, #3
c0de0c40:	3b04      	subs	r3, #4
c0de0c42:	089b      	lsrs	r3, r3, #2
c0de0c44:	3301      	adds	r3, #1
c0de0c46:	009b      	lsls	r3, r3, #2
c0de0c48:	18ed      	adds	r5, r5, r3
c0de0c4a:	18c9      	adds	r1, r1, r3
c0de0c4c:	4022      	ands	r2, r4
c0de0c4e:	e7bc      	b.n	c0de0bca <memmove+0x2a>
c0de0c50:	1e56      	subs	r6, r2, #1
c0de0c52:	0005      	movs	r5, r0
c0de0c54:	e7bc      	b.n	c0de0bd0 <memmove+0x30>
c0de0c56:	001a      	movs	r2, r3
c0de0c58:	e7b7      	b.n	c0de0bca <memmove+0x2a>
c0de0c5a:	46c0      	nop			; (mov r8, r8)

c0de0c5c <memset>:
c0de0c5c:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de0c5e:	0005      	movs	r5, r0
c0de0c60:	0783      	lsls	r3, r0, #30
c0de0c62:	d04a      	beq.n	c0de0cfa <memset+0x9e>
c0de0c64:	1e54      	subs	r4, r2, #1
c0de0c66:	2a00      	cmp	r2, #0
c0de0c68:	d044      	beq.n	c0de0cf4 <memset+0x98>
c0de0c6a:	b2ce      	uxtb	r6, r1
c0de0c6c:	0003      	movs	r3, r0
c0de0c6e:	2203      	movs	r2, #3
c0de0c70:	e002      	b.n	c0de0c78 <memset+0x1c>
c0de0c72:	3501      	adds	r5, #1
c0de0c74:	3c01      	subs	r4, #1
c0de0c76:	d33d      	bcc.n	c0de0cf4 <memset+0x98>
c0de0c78:	3301      	adds	r3, #1
c0de0c7a:	702e      	strb	r6, [r5, #0]
c0de0c7c:	4213      	tst	r3, r2
c0de0c7e:	d1f8      	bne.n	c0de0c72 <memset+0x16>
c0de0c80:	2c03      	cmp	r4, #3
c0de0c82:	d92f      	bls.n	c0de0ce4 <memset+0x88>
c0de0c84:	22ff      	movs	r2, #255	; 0xff
c0de0c86:	400a      	ands	r2, r1
c0de0c88:	0215      	lsls	r5, r2, #8
c0de0c8a:	4315      	orrs	r5, r2
c0de0c8c:	042a      	lsls	r2, r5, #16
c0de0c8e:	4315      	orrs	r5, r2
c0de0c90:	2c0f      	cmp	r4, #15
c0de0c92:	d935      	bls.n	c0de0d00 <memset+0xa4>
c0de0c94:	0027      	movs	r7, r4
c0de0c96:	3f10      	subs	r7, #16
c0de0c98:	093f      	lsrs	r7, r7, #4
c0de0c9a:	013e      	lsls	r6, r7, #4
c0de0c9c:	46b4      	mov	ip, r6
c0de0c9e:	001e      	movs	r6, r3
c0de0ca0:	001a      	movs	r2, r3
c0de0ca2:	3610      	adds	r6, #16
c0de0ca4:	4466      	add	r6, ip
c0de0ca6:	6015      	str	r5, [r2, #0]
c0de0ca8:	6055      	str	r5, [r2, #4]
c0de0caa:	6095      	str	r5, [r2, #8]
c0de0cac:	60d5      	str	r5, [r2, #12]
c0de0cae:	3210      	adds	r2, #16
c0de0cb0:	42b2      	cmp	r2, r6
c0de0cb2:	d1f8      	bne.n	c0de0ca6 <memset+0x4a>
c0de0cb4:	260f      	movs	r6, #15
c0de0cb6:	220c      	movs	r2, #12
c0de0cb8:	3701      	adds	r7, #1
c0de0cba:	013f      	lsls	r7, r7, #4
c0de0cbc:	4026      	ands	r6, r4
c0de0cbe:	19db      	adds	r3, r3, r7
c0de0cc0:	0037      	movs	r7, r6
c0de0cc2:	4222      	tst	r2, r4
c0de0cc4:	d017      	beq.n	c0de0cf6 <memset+0x9a>
c0de0cc6:	1f3e      	subs	r6, r7, #4
c0de0cc8:	08b6      	lsrs	r6, r6, #2
c0de0cca:	00b4      	lsls	r4, r6, #2
c0de0ccc:	46a4      	mov	ip, r4
c0de0cce:	001a      	movs	r2, r3
c0de0cd0:	1d1c      	adds	r4, r3, #4
c0de0cd2:	4464      	add	r4, ip
c0de0cd4:	c220      	stmia	r2!, {r5}
c0de0cd6:	42a2      	cmp	r2, r4
c0de0cd8:	d1fc      	bne.n	c0de0cd4 <memset+0x78>
c0de0cda:	2403      	movs	r4, #3
c0de0cdc:	3601      	adds	r6, #1
c0de0cde:	00b6      	lsls	r6, r6, #2
c0de0ce0:	199b      	adds	r3, r3, r6
c0de0ce2:	403c      	ands	r4, r7
c0de0ce4:	2c00      	cmp	r4, #0
c0de0ce6:	d005      	beq.n	c0de0cf4 <memset+0x98>
c0de0ce8:	b2c9      	uxtb	r1, r1
c0de0cea:	191c      	adds	r4, r3, r4
c0de0cec:	7019      	strb	r1, [r3, #0]
c0de0cee:	3301      	adds	r3, #1
c0de0cf0:	429c      	cmp	r4, r3
c0de0cf2:	d1fb      	bne.n	c0de0cec <memset+0x90>
c0de0cf4:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0de0cf6:	0034      	movs	r4, r6
c0de0cf8:	e7f4      	b.n	c0de0ce4 <memset+0x88>
c0de0cfa:	0014      	movs	r4, r2
c0de0cfc:	0003      	movs	r3, r0
c0de0cfe:	e7bf      	b.n	c0de0c80 <memset+0x24>
c0de0d00:	0027      	movs	r7, r4
c0de0d02:	e7e0      	b.n	c0de0cc6 <memset+0x6a>

c0de0d04 <setjmp>:
c0de0d04:	c0f0      	stmia	r0!, {r4, r5, r6, r7}
c0de0d06:	4641      	mov	r1, r8
c0de0d08:	464a      	mov	r2, r9
c0de0d0a:	4653      	mov	r3, sl
c0de0d0c:	465c      	mov	r4, fp
c0de0d0e:	466d      	mov	r5, sp
c0de0d10:	4676      	mov	r6, lr
c0de0d12:	c07e      	stmia	r0!, {r1, r2, r3, r4, r5, r6}
c0de0d14:	3828      	subs	r0, #40	; 0x28
c0de0d16:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0de0d18:	2000      	movs	r0, #0
c0de0d1a:	4770      	bx	lr

c0de0d1c <longjmp>:
c0de0d1c:	3010      	adds	r0, #16
c0de0d1e:	c87c      	ldmia	r0!, {r2, r3, r4, r5, r6}
c0de0d20:	4690      	mov	r8, r2
c0de0d22:	4699      	mov	r9, r3
c0de0d24:	46a2      	mov	sl, r4
c0de0d26:	46ab      	mov	fp, r5
c0de0d28:	46b5      	mov	sp, r6
c0de0d2a:	c808      	ldmia	r0!, {r3}
c0de0d2c:	3828      	subs	r0, #40	; 0x28
c0de0d2e:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0de0d30:	1c08      	adds	r0, r1, #0
c0de0d32:	d100      	bne.n	c0de0d36 <longjmp+0x1a>
c0de0d34:	2001      	movs	r0, #1
c0de0d36:	4718      	bx	r3

c0de0d38 <strlcpy>:
c0de0d38:	b5f0      	push	{r4, r5, r6, r7, lr}
c0de0d3a:	2a00      	cmp	r2, #0
c0de0d3c:	d013      	beq.n	c0de0d66 <strlcpy+0x2e>
c0de0d3e:	3a01      	subs	r2, #1
c0de0d40:	2a00      	cmp	r2, #0
c0de0d42:	d019      	beq.n	c0de0d78 <strlcpy+0x40>
c0de0d44:	2300      	movs	r3, #0
c0de0d46:	1c4f      	adds	r7, r1, #1
c0de0d48:	1c46      	adds	r6, r0, #1
c0de0d4a:	e002      	b.n	c0de0d52 <strlcpy+0x1a>
c0de0d4c:	3301      	adds	r3, #1
c0de0d4e:	429a      	cmp	r2, r3
c0de0d50:	d016      	beq.n	c0de0d80 <strlcpy+0x48>
c0de0d52:	18f5      	adds	r5, r6, r3
c0de0d54:	46ac      	mov	ip, r5
c0de0d56:	5ccd      	ldrb	r5, [r1, r3]
c0de0d58:	18fc      	adds	r4, r7, r3
c0de0d5a:	54c5      	strb	r5, [r0, r3]
c0de0d5c:	2d00      	cmp	r5, #0
c0de0d5e:	d1f5      	bne.n	c0de0d4c <strlcpy+0x14>
c0de0d60:	1a60      	subs	r0, r4, r1
c0de0d62:	3801      	subs	r0, #1
c0de0d64:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0de0d66:	000c      	movs	r4, r1
c0de0d68:	0023      	movs	r3, r4
c0de0d6a:	3301      	adds	r3, #1
c0de0d6c:	1e5a      	subs	r2, r3, #1
c0de0d6e:	7812      	ldrb	r2, [r2, #0]
c0de0d70:	001c      	movs	r4, r3
c0de0d72:	2a00      	cmp	r2, #0
c0de0d74:	d1f9      	bne.n	c0de0d6a <strlcpy+0x32>
c0de0d76:	e7f3      	b.n	c0de0d60 <strlcpy+0x28>
c0de0d78:	000c      	movs	r4, r1
c0de0d7a:	2300      	movs	r3, #0
c0de0d7c:	7003      	strb	r3, [r0, #0]
c0de0d7e:	e7f3      	b.n	c0de0d68 <strlcpy+0x30>
c0de0d80:	4660      	mov	r0, ip
c0de0d82:	e7fa      	b.n	c0de0d7a <strlcpy+0x42>

c0de0d84 <strnlen>:
c0de0d84:	b510      	push	{r4, lr}
c0de0d86:	2900      	cmp	r1, #0
c0de0d88:	d00b      	beq.n	c0de0da2 <strnlen+0x1e>
c0de0d8a:	7803      	ldrb	r3, [r0, #0]
c0de0d8c:	2b00      	cmp	r3, #0
c0de0d8e:	d00c      	beq.n	c0de0daa <strnlen+0x26>
c0de0d90:	1844      	adds	r4, r0, r1
c0de0d92:	0003      	movs	r3, r0
c0de0d94:	e002      	b.n	c0de0d9c <strnlen+0x18>
c0de0d96:	781a      	ldrb	r2, [r3, #0]
c0de0d98:	2a00      	cmp	r2, #0
c0de0d9a:	d004      	beq.n	c0de0da6 <strnlen+0x22>
c0de0d9c:	3301      	adds	r3, #1
c0de0d9e:	42a3      	cmp	r3, r4
c0de0da0:	d1f9      	bne.n	c0de0d96 <strnlen+0x12>
c0de0da2:	0008      	movs	r0, r1
c0de0da4:	bd10      	pop	{r4, pc}
c0de0da6:	1a19      	subs	r1, r3, r0
c0de0da8:	e7fb      	b.n	c0de0da2 <strnlen+0x1e>
c0de0daa:	2100      	movs	r1, #0
c0de0dac:	e7f9      	b.n	c0de0da2 <strnlen+0x1e>
c0de0dae:	46c0      	nop			; (mov r8, r8)
c0de0db0:	7055      	strb	r5, [r2, #1]
c0de0db2:	7264      	strb	r4, [r4, #9]
c0de0db4:	6761      	str	r1, [r4, #116]	; 0x74
c0de0db6:	0065      	lsls	r5, r4, #1
c0de0db8:	6c50      	ldr	r0, [r2, #68]	; 0x44
c0de0dba:	6775      	str	r5, [r6, #116]	; 0x74
c0de0dbc:	6e69      	ldr	r1, [r5, #100]	; 0x64
c0de0dbe:	7020      	strb	r0, [r4, #0]
c0de0dc0:	7261      	strb	r1, [r4, #9]
c0de0dc2:	6d61      	ldr	r1, [r4, #84]	; 0x54
c0de0dc4:	7465      	strb	r5, [r4, #17]
c0de0dc6:	7265      	strb	r5, [r4, #9]
c0de0dc8:	2073      	movs	r0, #115	; 0x73
c0de0dca:	7473      	strb	r3, [r6, #17]
c0de0dcc:	7572      	strb	r2, [r6, #21]
c0de0dce:	7463      	strb	r3, [r4, #17]
c0de0dd0:	7275      	strb	r5, [r6, #9]
c0de0dd2:	2065      	movs	r0, #101	; 0x65
c0de0dd4:	7369      	strb	r1, [r5, #13]
c0de0dd6:	6220      	str	r0, [r4, #32]
c0de0dd8:	6769      	str	r1, [r5, #116]	; 0x74
c0de0dda:	6567      	str	r7, [r4, #84]	; 0x54
c0de0ddc:	2072      	movs	r0, #114	; 0x72
c0de0dde:	6874      	ldr	r4, [r6, #4]
c0de0de0:	6e61      	ldr	r1, [r4, #100]	; 0x64
c0de0de2:	6120      	str	r0, [r4, #16]
c0de0de4:	6c6c      	ldr	r4, [r5, #68]	; 0x44
c0de0de6:	776f      	strb	r7, [r5, #29]
c0de0de8:	6465      	str	r5, [r4, #68]	; 0x44
c0de0dea:	7320      	strb	r0, [r4, #12]
c0de0dec:	7a69      	ldrb	r1, [r5, #9]
c0de0dee:	0a65      	lsrs	r5, r4, #9
c0de0df0:	5200      	strh	r0, [r0, r0]
c0de0df2:	6369      	str	r1, [r5, #52]	; 0x34
c0de0df4:	636f      	str	r7, [r5, #52]	; 0x34
c0de0df6:	6568      	str	r0, [r5, #84]	; 0x54
c0de0df8:	0074      	lsls	r4, r6, #1
c0de0dfa:	6553      	str	r3, [r2, #84]	; 0x54
c0de0dfc:	656c      	str	r4, [r5, #84]	; 0x54
c0de0dfe:	7463      	strb	r3, [r4, #17]
c0de0e00:	726f      	strb	r7, [r5, #9]
c0de0e02:	6920      	ldr	r0, [r4, #16]
c0de0e04:	646e      	str	r6, [r5, #68]	; 0x44
c0de0e06:	7865      	ldrb	r5, [r4, #1]
c0de0e08:	203a      	movs	r0, #58	; 0x3a
c0de0e0a:	6425      	str	r5, [r4, #64]	; 0x40
c0de0e0c:	6e20      	ldr	r0, [r4, #96]	; 0x60
c0de0e0e:	746f      	strb	r7, [r5, #17]
c0de0e10:	7320      	strb	r0, [r4, #12]
c0de0e12:	7075      	strb	r5, [r6, #1]
c0de0e14:	6f70      	ldr	r0, [r6, #116]	; 0x74
c0de0e16:	7472      	strb	r2, [r6, #17]
c0de0e18:	6465      	str	r5, [r4, #68]	; 0x44
c0de0e1a:	000a      	movs	r2, r1
c0de0e1c:	6d41      	ldr	r1, [r0, #84]	; 0x54
c0de0e1e:	756f      	strb	r7, [r5, #21]
c0de0e20:	746e      	strb	r6, [r5, #17]
c0de0e22:	2000      	movs	r0, #0
c0de0e24:	5000      	str	r0, [r0, r0]
c0de0e26:	7261      	strb	r1, [r4, #9]
c0de0e28:	6d61      	ldr	r1, [r4, #84]	; 0x54
c0de0e2a:	6e20      	ldr	r0, [r4, #96]	; 0x60
c0de0e2c:	746f      	strb	r7, [r5, #17]
c0de0e2e:	7320      	strb	r0, [r4, #12]
c0de0e30:	7075      	strb	r5, [r6, #1]
c0de0e32:	6f70      	ldr	r0, [r6, #116]	; 0x74
c0de0e34:	7472      	strb	r2, [r6, #17]
c0de0e36:	6465      	str	r5, [r4, #68]	; 0x44
c0de0e38:	000a      	movs	r2, r1
c0de0e3a:	7445      	strb	r5, [r0, #17]
c0de0e3c:	6568      	str	r0, [r5, #84]	; 0x54
c0de0e3e:	6572      	str	r2, [r6, #84]	; 0x54
c0de0e40:	6d75      	ldr	r5, [r6, #84]	; 0x54
c0de0e42:	3000      	adds	r0, #0
c0de0e44:	6f00      	ldr	r0, [r0, #112]	; 0x70
c0de0e46:	6666      	str	r6, [r4, #100]	; 0x64
c0de0e48:	6573      	str	r3, [r6, #84]	; 0x54
c0de0e4a:	3a74      	subs	r2, #116	; 0x74
c0de0e4c:	2520      	movs	r5, #32
c0de0e4e:	2c64      	cmp	r4, #100	; 0x64
c0de0e50:	6320      	str	r0, [r4, #48]	; 0x30
c0de0e52:	6568      	str	r0, [r5, #84]	; 0x54
c0de0e54:	6b63      	ldr	r3, [r4, #52]	; 0x34
c0de0e56:	6f70      	ldr	r0, [r6, #116]	; 0x74
c0de0e58:	6e69      	ldr	r1, [r5, #100]	; 0x64
c0de0e5a:	3a74      	subs	r2, #116	; 0x74
c0de0e5c:	2520      	movs	r5, #32
c0de0e5e:	2c64      	cmp	r4, #100	; 0x64
c0de0e60:	7020      	strb	r0, [r4, #0]
c0de0e62:	7261      	strb	r1, [r4, #9]
c0de0e64:	6d61      	ldr	r1, [r4, #84]	; 0x54
c0de0e66:	7465      	strb	r5, [r4, #17]
c0de0e68:	7265      	strb	r5, [r4, #9]
c0de0e6a:	664f      	str	r7, [r1, #100]	; 0x64
c0de0e6c:	7366      	strb	r6, [r4, #13]
c0de0e6e:	7465      	strb	r5, [r4, #17]
c0de0e70:	203a      	movs	r0, #58	; 0x3a
c0de0e72:	6425      	str	r5, [r4, #64]	; 0x40
c0de0e74:	000a      	movs	r2, r1
c0de0e76:	7865      	ldrb	r5, [r4, #1]
c0de0e78:	6563      	str	r3, [r4, #84]	; 0x54
c0de0e7a:	7470      	strb	r0, [r6, #17]
c0de0e7c:	6f69      	ldr	r1, [r5, #116]	; 0x74
c0de0e7e:	5b6e      	ldrh	r6, [r5, r5]
c0de0e80:	6425      	str	r5, [r4, #64]	; 0x40
c0de0e82:	3a5d      	subs	r2, #93	; 0x5d
c0de0e84:	4c20      	ldr	r4, [pc, #128]	; (c0de0f08 <strnlen+0x184>)
c0de0e86:	3d52      	subs	r5, #82	; 0x52
c0de0e88:	7830      	ldrb	r0, [r6, #0]
c0de0e8a:	3025      	adds	r0, #37	; 0x25
c0de0e8c:	5838      	ldr	r0, [r7, r0]
c0de0e8e:	000a      	movs	r2, r1
c0de0e90:	5245      	strh	r5, [r0, r1]
c0de0e92:	4f52      	ldr	r7, [pc, #328]	; (c0de0fdc <_etext+0xa8>)
c0de0e94:	0052      	lsls	r2, r2, #1
c0de0e96:	6553      	str	r3, [r2, #84]	; 0x54
c0de0e98:	656c      	str	r4, [r5, #84]	; 0x54
c0de0e9a:	7463      	strb	r3, [r4, #17]
c0de0e9c:	726f      	strb	r7, [r5, #9]
c0de0e9e:	4920      	ldr	r1, [pc, #128]	; (c0de0f20 <g_pcHex+0xc>)
c0de0ea0:	646e      	str	r6, [r5, #68]	; 0x44
c0de0ea2:	7865      	ldrb	r5, [r4, #1]
c0de0ea4:	6e20      	ldr	r0, [r4, #96]	; 0x60
c0de0ea6:	746f      	strb	r7, [r5, #17]
c0de0ea8:	7320      	strb	r0, [r4, #12]
c0de0eaa:	7075      	strb	r5, [r6, #1]
c0de0eac:	6f70      	ldr	r0, [r6, #116]	; 0x74
c0de0eae:	7472      	strb	r2, [r6, #17]
c0de0eb0:	6465      	str	r5, [r4, #68]	; 0x44
c0de0eb2:	203a      	movs	r0, #58	; 0x3a
c0de0eb4:	6425      	str	r5, [r4, #64]	; 0x40
c0de0eb6:	000a      	movs	r2, r1
c0de0eb8:	6e55      	ldr	r5, [r2, #100]	; 0x64
c0de0eba:	6168      	str	r0, [r5, #20]
c0de0ebc:	646e      	str	r6, [r5, #68]	; 0x44
c0de0ebe:	656c      	str	r4, [r5, #84]	; 0x54
c0de0ec0:	2064      	movs	r0, #100	; 0x64
c0de0ec2:	656d      	str	r5, [r5, #84]	; 0x54
c0de0ec4:	7373      	strb	r3, [r6, #13]
c0de0ec6:	6761      	str	r1, [r4, #116]	; 0x74
c0de0ec8:	2065      	movs	r0, #101	; 0x65
c0de0eca:	6425      	str	r5, [r4, #64]	; 0x40
c0de0ecc:	000a      	movs	r2, r1
c0de0ece:	6552      	str	r2, [r2, #84]	; 0x54
c0de0ed0:	6563      	str	r3, [r4, #84]	; 0x54
c0de0ed2:	7669      	strb	r1, [r5, #25]
c0de0ed4:	6465      	str	r5, [r4, #68]	; 0x44
c0de0ed6:	6120      	str	r0, [r4, #16]
c0de0ed8:	206e      	movs	r0, #110	; 0x6e
c0de0eda:	6e69      	ldr	r1, [r5, #100]	; 0x64
c0de0edc:	6176      	str	r6, [r6, #20]
c0de0ede:	696c      	ldr	r4, [r5, #20]
c0de0ee0:	2064      	movs	r0, #100	; 0x64
c0de0ee2:	6373      	str	r3, [r6, #52]	; 0x34
c0de0ee4:	6572      	str	r2, [r6, #84]	; 0x54
c0de0ee6:	6e65      	ldr	r5, [r4, #100]	; 0x64
c0de0ee8:	6e49      	ldr	r1, [r1, #100]	; 0x64
c0de0eea:	6564      	str	r4, [r4, #84]	; 0x54
c0de0eec:	0a78      	lsrs	r0, r7, #9
c0de0eee:	0000      	movs	r0, r0
c0de0ef0:	694d      	ldr	r5, [r1, #20]
c0de0ef2:	7373      	strb	r3, [r6, #13]
c0de0ef4:	6e69      	ldr	r1, [r5, #100]	; 0x64
c0de0ef6:	2067      	movs	r0, #103	; 0x67
c0de0ef8:	6573      	str	r3, [r6, #84]	; 0x54
c0de0efa:	656c      	str	r4, [r5, #84]	; 0x54
c0de0efc:	7463      	strb	r3, [r4, #17]
c0de0efe:	726f      	strb	r7, [r5, #9]
c0de0f00:	6e49      	ldr	r1, [r1, #100]	; 0x64
c0de0f02:	6564      	str	r4, [r4, #84]	; 0x54
c0de0f04:	3a78      	subs	r2, #120	; 0x78
c0de0f06:	2520      	movs	r5, #32
c0de0f08:	0a64      	lsrs	r4, r4, #9
	...

c0de0f0b <UPGRADE_SELECTOR>:
c0de0f0b:	9745 037d                                    E.}..

c0de0f10 <RICOCHET_SELECTORS>:
c0de0f10:	0f0b c0de                                   ....

c0de0f14 <g_pcHex>:
c0de0f14:	3130 3332 3534 3736 3938 6261 6463 6665     0123456789abcdef

c0de0f24 <g_pcHex_cap>:
c0de0f24:	3130 3332 3534 3736 3938 4241 4443 4645     0123456789ABCDEF

c0de0f34 <_etext>:
c0de0f34:	d4d4      	bmi.n	c0de0ee0 <strnlen+0x15c>
c0de0f36:	d4d4      	bmi.n	c0de0ee2 <strnlen+0x15e>
c0de0f38:	d4d4      	bmi.n	c0de0ee4 <strnlen+0x160>
c0de0f3a:	d4d4      	bmi.n	c0de0ee6 <strnlen+0x162>
c0de0f3c:	d4d4      	bmi.n	c0de0ee8 <strnlen+0x164>
c0de0f3e:	d4d4      	bmi.n	c0de0eea <strnlen+0x166>
c0de0f40:	d4d4      	bmi.n	c0de0eec <strnlen+0x168>
c0de0f42:	d4d4      	bmi.n	c0de0eee <strnlen+0x16a>
c0de0f44:	d4d4      	bmi.n	c0de0ef0 <strnlen+0x16c>
c0de0f46:	d4d4      	bmi.n	c0de0ef2 <strnlen+0x16e>
c0de0f48:	d4d4      	bmi.n	c0de0ef4 <strnlen+0x170>
c0de0f4a:	d4d4      	bmi.n	c0de0ef6 <strnlen+0x172>
c0de0f4c:	d4d4      	bmi.n	c0de0ef8 <strnlen+0x174>
c0de0f4e:	d4d4      	bmi.n	c0de0efa <strnlen+0x176>
c0de0f50:	d4d4      	bmi.n	c0de0efc <strnlen+0x178>
c0de0f52:	d4d4      	bmi.n	c0de0efe <strnlen+0x17a>
c0de0f54:	d4d4      	bmi.n	c0de0f00 <strnlen+0x17c>
c0de0f56:	d4d4      	bmi.n	c0de0f02 <strnlen+0x17e>
c0de0f58:	d4d4      	bmi.n	c0de0f04 <strnlen+0x180>
c0de0f5a:	d4d4      	bmi.n	c0de0f06 <strnlen+0x182>
c0de0f5c:	d4d4      	bmi.n	c0de0f08 <strnlen+0x184>
c0de0f5e:	d4d4      	bmi.n	c0de0f0a <strnlen+0x186>
c0de0f60:	d4d4      	bmi.n	c0de0f0c <UPGRADE_SELECTOR+0x1>
c0de0f62:	d4d4      	bmi.n	c0de0f0e <UPGRADE_SELECTOR+0x3>
c0de0f64:	d4d4      	bmi.n	c0de0f10 <RICOCHET_SELECTORS>
c0de0f66:	d4d4      	bmi.n	c0de0f12 <RICOCHET_SELECTORS+0x2>
c0de0f68:	d4d4      	bmi.n	c0de0f14 <g_pcHex>
c0de0f6a:	d4d4      	bmi.n	c0de0f16 <g_pcHex+0x2>
c0de0f6c:	d4d4      	bmi.n	c0de0f18 <g_pcHex+0x4>
c0de0f6e:	d4d4      	bmi.n	c0de0f1a <g_pcHex+0x6>
c0de0f70:	d4d4      	bmi.n	c0de0f1c <g_pcHex+0x8>
c0de0f72:	d4d4      	bmi.n	c0de0f1e <g_pcHex+0xa>
c0de0f74:	d4d4      	bmi.n	c0de0f20 <g_pcHex+0xc>
c0de0f76:	d4d4      	bmi.n	c0de0f22 <g_pcHex+0xe>
c0de0f78:	d4d4      	bmi.n	c0de0f24 <g_pcHex_cap>
c0de0f7a:	d4d4      	bmi.n	c0de0f26 <g_pcHex_cap+0x2>
c0de0f7c:	d4d4      	bmi.n	c0de0f28 <g_pcHex_cap+0x4>
c0de0f7e:	d4d4      	bmi.n	c0de0f2a <g_pcHex_cap+0x6>
c0de0f80:	d4d4      	bmi.n	c0de0f2c <g_pcHex_cap+0x8>
c0de0f82:	d4d4      	bmi.n	c0de0f2e <g_pcHex_cap+0xa>
c0de0f84:	d4d4      	bmi.n	c0de0f30 <g_pcHex_cap+0xc>
c0de0f86:	d4d4      	bmi.n	c0de0f32 <g_pcHex_cap+0xe>
c0de0f88:	d4d4      	bmi.n	c0de0f34 <_etext>
c0de0f8a:	d4d4      	bmi.n	c0de0f36 <_etext+0x2>
c0de0f8c:	d4d4      	bmi.n	c0de0f38 <_etext+0x4>
c0de0f8e:	d4d4      	bmi.n	c0de0f3a <_etext+0x6>
c0de0f90:	d4d4      	bmi.n	c0de0f3c <_etext+0x8>
c0de0f92:	d4d4      	bmi.n	c0de0f3e <_etext+0xa>
c0de0f94:	d4d4      	bmi.n	c0de0f40 <_etext+0xc>
c0de0f96:	d4d4      	bmi.n	c0de0f42 <_etext+0xe>
c0de0f98:	d4d4      	bmi.n	c0de0f44 <_etext+0x10>
c0de0f9a:	d4d4      	bmi.n	c0de0f46 <_etext+0x12>
c0de0f9c:	d4d4      	bmi.n	c0de0f48 <_etext+0x14>
c0de0f9e:	d4d4      	bmi.n	c0de0f4a <_etext+0x16>
c0de0fa0:	d4d4      	bmi.n	c0de0f4c <_etext+0x18>
c0de0fa2:	d4d4      	bmi.n	c0de0f4e <_etext+0x1a>
c0de0fa4:	d4d4      	bmi.n	c0de0f50 <_etext+0x1c>
c0de0fa6:	d4d4      	bmi.n	c0de0f52 <_etext+0x1e>
c0de0fa8:	d4d4      	bmi.n	c0de0f54 <_etext+0x20>
c0de0faa:	d4d4      	bmi.n	c0de0f56 <_etext+0x22>
c0de0fac:	d4d4      	bmi.n	c0de0f58 <_etext+0x24>
c0de0fae:	d4d4      	bmi.n	c0de0f5a <_etext+0x26>
c0de0fb0:	d4d4      	bmi.n	c0de0f5c <_etext+0x28>
c0de0fb2:	d4d4      	bmi.n	c0de0f5e <_etext+0x2a>
c0de0fb4:	d4d4      	bmi.n	c0de0f60 <_etext+0x2c>
c0de0fb6:	d4d4      	bmi.n	c0de0f62 <_etext+0x2e>
c0de0fb8:	d4d4      	bmi.n	c0de0f64 <_etext+0x30>
c0de0fba:	d4d4      	bmi.n	c0de0f66 <_etext+0x32>
c0de0fbc:	d4d4      	bmi.n	c0de0f68 <_etext+0x34>
c0de0fbe:	d4d4      	bmi.n	c0de0f6a <_etext+0x36>
c0de0fc0:	d4d4      	bmi.n	c0de0f6c <_etext+0x38>
c0de0fc2:	d4d4      	bmi.n	c0de0f6e <_etext+0x3a>
c0de0fc4:	d4d4      	bmi.n	c0de0f70 <_etext+0x3c>
c0de0fc6:	d4d4      	bmi.n	c0de0f72 <_etext+0x3e>
c0de0fc8:	d4d4      	bmi.n	c0de0f74 <_etext+0x40>
c0de0fca:	d4d4      	bmi.n	c0de0f76 <_etext+0x42>
c0de0fcc:	d4d4      	bmi.n	c0de0f78 <_etext+0x44>
c0de0fce:	d4d4      	bmi.n	c0de0f7a <_etext+0x46>
c0de0fd0:	d4d4      	bmi.n	c0de0f7c <_etext+0x48>
c0de0fd2:	d4d4      	bmi.n	c0de0f7e <_etext+0x4a>
c0de0fd4:	d4d4      	bmi.n	c0de0f80 <_etext+0x4c>
c0de0fd6:	d4d4      	bmi.n	c0de0f82 <_etext+0x4e>
c0de0fd8:	d4d4      	bmi.n	c0de0f84 <_etext+0x50>
c0de0fda:	d4d4      	bmi.n	c0de0f86 <_etext+0x52>
c0de0fdc:	d4d4      	bmi.n	c0de0f88 <_etext+0x54>
c0de0fde:	d4d4      	bmi.n	c0de0f8a <_etext+0x56>
c0de0fe0:	d4d4      	bmi.n	c0de0f8c <_etext+0x58>
c0de0fe2:	d4d4      	bmi.n	c0de0f8e <_etext+0x5a>
c0de0fe4:	d4d4      	bmi.n	c0de0f90 <_etext+0x5c>
c0de0fe6:	d4d4      	bmi.n	c0de0f92 <_etext+0x5e>
c0de0fe8:	d4d4      	bmi.n	c0de0f94 <_etext+0x60>
c0de0fea:	d4d4      	bmi.n	c0de0f96 <_etext+0x62>
c0de0fec:	d4d4      	bmi.n	c0de0f98 <_etext+0x64>
c0de0fee:	d4d4      	bmi.n	c0de0f9a <_etext+0x66>
c0de0ff0:	d4d4      	bmi.n	c0de0f9c <_etext+0x68>
c0de0ff2:	d4d4      	bmi.n	c0de0f9e <_etext+0x6a>
c0de0ff4:	d4d4      	bmi.n	c0de0fa0 <_etext+0x6c>
c0de0ff6:	d4d4      	bmi.n	c0de0fa2 <_etext+0x6e>
c0de0ff8:	d4d4      	bmi.n	c0de0fa4 <_etext+0x70>
c0de0ffa:	d4d4      	bmi.n	c0de0fa6 <_etext+0x72>
c0de0ffc:	d4d4      	bmi.n	c0de0fa8 <_etext+0x74>
c0de0ffe:	d4d4      	bmi.n	c0de0faa <_etext+0x76>
