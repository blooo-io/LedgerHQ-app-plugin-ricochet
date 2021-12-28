
bin/app.elf:     file format elf32-littlearm


Disassembly of section .text:

c0d00000 <main>:
    libcall_params[2] = RUN_APPLICATION;
    os_lib_call((unsigned int *) &libcall_params);
}

// Weird low-level black magic. No need to edit this.
__attribute__((section(".boot"))) int main(int arg0) {
c0d00000:	b5b0      	push	{r4, r5, r7, lr}
c0d00002:	b090      	sub	sp, #64	; 0x40
c0d00004:	4604      	mov	r4, r0
    // Exit critical section
    __asm volatile("cpsie i");
c0d00006:	b662      	cpsie	i

    // Ensure exception will work as planned
    os_boot();
c0d00008:	f000 fa3d 	bl	c0d00486 <os_boot>
c0d0000c:	ad01      	add	r5, sp, #4

    // Try catch block. Please read the docs for more information on how to use those!
    BEGIN_TRY {
        TRY {
c0d0000e:	4628      	mov	r0, r5
c0d00010:	f000 fb76 	bl	c0d00700 <setjmp>
c0d00014:	85a8      	strh	r0, [r5, #44]	; 0x2c
c0d00016:	0400      	lsls	r0, r0, #16
c0d00018:	d117      	bne.n	c0d0004a <main+0x4a>
c0d0001a:	a801      	add	r0, sp, #4
c0d0001c:	f000 fa9e 	bl	c0d0055c <try_context_set>
c0d00020:	900b      	str	r0, [sp, #44]	; 0x2c
// get API level
SYSCALL unsigned int get_api_level(void);

#ifndef HAVE_BOLOS
static inline void check_api_level(unsigned int apiLevel) {
  if (apiLevel < get_api_level()) {
c0d00022:	f000 fa59 	bl	c0d004d8 <get_api_level>
c0d00026:	280d      	cmp	r0, #13
c0d00028:	d302      	bcc.n	c0d00030 <main+0x30>
c0d0002a:	20ff      	movs	r0, #255	; 0xff
    os_sched_exit(-1);
c0d0002c:	f000 fa7c 	bl	c0d00528 <os_sched_exit>
c0d00030:	2001      	movs	r0, #1
c0d00032:	0201      	lsls	r1, r0, #8
            // Low-level black magic.
            check_api_level(CX_COMPAT_APILEVEL);

            // Check if we are called from the dashboard.
            if (!arg0) {
c0d00034:	2c00      	cmp	r4, #0
c0d00036:	d017      	beq.n	c0d00068 <main+0x68>
                // Not called from dashboard: called from the ethereum app!
                unsigned int *args = (unsigned int *) arg0;

                // If `ETH_PLUGIN_CHECK_PRESENCE` is set, this means the caller is just trying to
                // know whether this app exists or not. We can skip `dispatch_plugin_calls`.
                if (args[0] != ETH_PLUGIN_CHECK_PRESENCE) {
c0d00038:	6820      	ldr	r0, [r4, #0]
c0d0003a:	31ff      	adds	r1, #255	; 0xff
c0d0003c:	4288      	cmp	r0, r1
c0d0003e:	d002      	beq.n	c0d00046 <main+0x46>
                    dispatch_plugin_calls(args[0], (void *) args[1]);
c0d00040:	6861      	ldr	r1, [r4, #4]
c0d00042:	f000 f9f5 	bl	c0d00430 <dispatch_plugin_calls>
                }

                // Call `os_lib_end`, go back to the ethereum app.
                os_lib_end();
c0d00046:	f000 fa63 	bl	c0d00510 <os_lib_end>
            }
        }
        FINALLY {
c0d0004a:	f000 fa7b 	bl	c0d00544 <try_context_get>
c0d0004e:	a901      	add	r1, sp, #4
c0d00050:	4288      	cmp	r0, r1
c0d00052:	d102      	bne.n	c0d0005a <main+0x5a>
c0d00054:	980b      	ldr	r0, [sp, #44]	; 0x2c
c0d00056:	f000 fa81 	bl	c0d0055c <try_context_set>
c0d0005a:	a801      	add	r0, sp, #4
        }
    }
    END_TRY;
c0d0005c:	8d80      	ldrh	r0, [r0, #44]	; 0x2c
c0d0005e:	2800      	cmp	r0, #0
c0d00060:	d10b      	bne.n	c0d0007a <main+0x7a>
c0d00062:	2000      	movs	r0, #0

    // Will not get reached.
    return 0;
}
c0d00064:	b010      	add	sp, #64	; 0x40
c0d00066:	bdb0      	pop	{r4, r5, r7, pc}
    libcall_params[2] = RUN_APPLICATION;
c0d00068:	900f      	str	r0, [sp, #60]	; 0x3c
    libcall_params[1] = 0x100;
c0d0006a:	910e      	str	r1, [sp, #56]	; 0x38
    libcall_params[0] = (unsigned int) "Ethereum";
c0d0006c:	4804      	ldr	r0, [pc, #16]	; (c0d00080 <main+0x80>)
c0d0006e:	4478      	add	r0, pc
c0d00070:	900d      	str	r0, [sp, #52]	; 0x34
c0d00072:	a80d      	add	r0, sp, #52	; 0x34
    os_lib_call((unsigned int *) &libcall_params);
c0d00074:	f000 fa3e 	bl	c0d004f4 <os_lib_call>
c0d00078:	e7f3      	b.n	c0d00062 <main+0x62>
    END_TRY;
c0d0007a:	f000 fa09 	bl	c0d00490 <os_longjmp>
c0d0007e:	46c0      	nop			; (mov r8, r8)
c0d00080:	00000762 	.word	0x00000762

c0d00084 <adjustDecimals>:

bool adjustDecimals(char *src,
                    uint32_t srcLength,
                    char *target,
                    uint32_t targetLength,
                    uint8_t decimals) {
c0d00084:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00086:	b081      	sub	sp, #4
c0d00088:	4614      	mov	r4, r2
c0d0008a:	460e      	mov	r6, r1
c0d0008c:	4605      	mov	r5, r0
    uint32_t startOffset;
    uint32_t lastZeroOffset = 0;
    uint32_t offset = 0;
    if ((srcLength == 1) && (*src == '0')) {
c0d0008e:	2901      	cmp	r1, #1
c0d00090:	d10a      	bne.n	c0d000a8 <adjustDecimals+0x24>
c0d00092:	7828      	ldrb	r0, [r5, #0]
c0d00094:	2830      	cmp	r0, #48	; 0x30
c0d00096:	d107      	bne.n	c0d000a8 <adjustDecimals+0x24>
        if (targetLength < 2) {
c0d00098:	2b02      	cmp	r3, #2
c0d0009a:	d32e      	bcc.n	c0d000fa <adjustDecimals+0x76>
c0d0009c:	2000      	movs	r0, #0
            return false;
        }
        target[0] = '0';
        target[1] = '\0';
c0d0009e:	7060      	strb	r0, [r4, #1]
c0d000a0:	2030      	movs	r0, #48	; 0x30
        target[0] = '0';
c0d000a2:	7020      	strb	r0, [r4, #0]
c0d000a4:	2001      	movs	r0, #1
c0d000a6:	e061      	b.n	c0d0016c <adjustDecimals+0xe8>
c0d000a8:	9806      	ldr	r0, [sp, #24]
        return true;
    }
    if (srcLength <= decimals) {
c0d000aa:	42b0      	cmp	r0, r6
c0d000ac:	d222      	bcs.n	c0d000f4 <adjustDecimals+0x70>
        }
        target[offset] = '\0';
    } else {
        uint32_t sourceOffset = 0;
        uint32_t delta = srcLength - decimals;
        if (targetLength < srcLength + 1 + 1) {
c0d000ae:	1cb1      	adds	r1, r6, #2
c0d000b0:	4299      	cmp	r1, r3
c0d000b2:	d822      	bhi.n	c0d000fa <adjustDecimals+0x76>
c0d000b4:	1a31      	subs	r1, r6, r0
            return false;
        }
        while (offset < delta) {
c0d000b6:	9100      	str	r1, [sp, #0]
c0d000b8:	d009      	beq.n	c0d000ce <adjustDecimals+0x4a>
c0d000ba:	4629      	mov	r1, r5
c0d000bc:	9b00      	ldr	r3, [sp, #0]
c0d000be:	4627      	mov	r7, r4
            target[offset++] = src[sourceOffset++];
c0d000c0:	780a      	ldrb	r2, [r1, #0]
c0d000c2:	703a      	strb	r2, [r7, #0]
        while (offset < delta) {
c0d000c4:	1c49      	adds	r1, r1, #1
c0d000c6:	1e5b      	subs	r3, r3, #1
c0d000c8:	1c7f      	adds	r7, r7, #1
c0d000ca:	2b00      	cmp	r3, #0
c0d000cc:	d1f8      	bne.n	c0d000c0 <adjustDecimals+0x3c>
        }
        if (decimals != 0) {
c0d000ce:	2800      	cmp	r0, #0
c0d000d0:	9a00      	ldr	r2, [sp, #0]
c0d000d2:	4611      	mov	r1, r2
c0d000d4:	d002      	beq.n	c0d000dc <adjustDecimals+0x58>
c0d000d6:	212e      	movs	r1, #46	; 0x2e
            target[offset++] = '.';
c0d000d8:	54a1      	strb	r1, [r4, r2]
c0d000da:	1c51      	adds	r1, r2, #1
        }
        startOffset = offset;
        while (sourceOffset < srcLength) {
c0d000dc:	42b2      	cmp	r2, r6
c0d000de:	d22a      	bcs.n	c0d00136 <adjustDecimals+0xb2>
c0d000e0:	1863      	adds	r3, r4, r1
c0d000e2:	18ad      	adds	r5, r5, r2
c0d000e4:	2200      	movs	r2, #0
            target[offset++] = src[sourceOffset++];
c0d000e6:	5cae      	ldrb	r6, [r5, r2]
c0d000e8:	549e      	strb	r6, [r3, r2]
        while (sourceOffset < srcLength) {
c0d000ea:	1c52      	adds	r2, r2, #1
c0d000ec:	4290      	cmp	r0, r2
c0d000ee:	d1fa      	bne.n	c0d000e6 <adjustDecimals+0x62>
c0d000f0:	188a      	adds	r2, r1, r2
c0d000f2:	e021      	b.n	c0d00138 <adjustDecimals+0xb4>
        if (targetLength < srcLength + 1 + 2 + delta) {
c0d000f4:	1cc1      	adds	r1, r0, #3
c0d000f6:	4299      	cmp	r1, r3
c0d000f8:	d901      	bls.n	c0d000fe <adjustDecimals+0x7a>
c0d000fa:	2000      	movs	r0, #0
c0d000fc:	e036      	b.n	c0d0016c <adjustDecimals+0xe8>
c0d000fe:	1b87      	subs	r7, r0, r6
c0d00100:	202e      	movs	r0, #46	; 0x2e
        target[offset++] = '.';
c0d00102:	7060      	strb	r0, [r4, #1]
c0d00104:	2030      	movs	r0, #48	; 0x30
        target[offset++] = '0';
c0d00106:	7020      	strb	r0, [r4, #0]
        for (uint32_t i = 0; i < delta; i++) {
c0d00108:	2f00      	cmp	r7, #0
c0d0010a:	d008      	beq.n	c0d0011e <adjustDecimals+0x9a>
c0d0010c:	1ca0      	adds	r0, r4, #2
c0d0010e:	2230      	movs	r2, #48	; 0x30
            target[offset++] = '0';
c0d00110:	4639      	mov	r1, r7
c0d00112:	f000 faca 	bl	c0d006aa <__aeabi_memset>
        for (uint32_t i = 0; i < delta; i++) {
c0d00116:	1cb9      	adds	r1, r7, #2
c0d00118:	1e7f      	subs	r7, r7, #1
c0d0011a:	d1fd      	bne.n	c0d00118 <adjustDecimals+0x94>
c0d0011c:	e000      	b.n	c0d00120 <adjustDecimals+0x9c>
c0d0011e:	2102      	movs	r1, #2
        for (uint32_t i = 0; i < srcLength; i++) {
c0d00120:	2e00      	cmp	r6, #0
c0d00122:	d008      	beq.n	c0d00136 <adjustDecimals+0xb2>
c0d00124:	1862      	adds	r2, r4, r1
c0d00126:	2000      	movs	r0, #0
            target[offset++] = src[i];
c0d00128:	5c2b      	ldrb	r3, [r5, r0]
c0d0012a:	5413      	strb	r3, [r2, r0]
        for (uint32_t i = 0; i < srcLength; i++) {
c0d0012c:	1c40      	adds	r0, r0, #1
c0d0012e:	4286      	cmp	r6, r0
c0d00130:	d1fa      	bne.n	c0d00128 <adjustDecimals+0xa4>
c0d00132:	180a      	adds	r2, r1, r0
c0d00134:	e000      	b.n	c0d00138 <adjustDecimals+0xb4>
c0d00136:	460a      	mov	r2, r1
c0d00138:	2500      	movs	r5, #0
c0d0013a:	54a5      	strb	r5, [r4, r2]
c0d0013c:	2001      	movs	r0, #1
        }
        target[offset] = '\0';
    }
    for (uint32_t i = startOffset; i < offset; i++) {
c0d0013e:	4291      	cmp	r1, r2
c0d00140:	d214      	bcs.n	c0d0016c <adjustDecimals+0xe8>
        if (target[i] == '0') {
c0d00142:	5c66      	ldrb	r6, [r4, r1]
c0d00144:	2d00      	cmp	r5, #0
c0d00146:	460b      	mov	r3, r1
c0d00148:	d000      	beq.n	c0d0014c <adjustDecimals+0xc8>
c0d0014a:	462b      	mov	r3, r5
c0d0014c:	2e30      	cmp	r6, #48	; 0x30
c0d0014e:	d000      	beq.n	c0d00152 <adjustDecimals+0xce>
c0d00150:	2300      	movs	r3, #0
    for (uint32_t i = startOffset; i < offset; i++) {
c0d00152:	1c49      	adds	r1, r1, #1
c0d00154:	428a      	cmp	r2, r1
c0d00156:	461d      	mov	r5, r3
c0d00158:	d1f3      	bne.n	c0d00142 <adjustDecimals+0xbe>
            }
        } else {
            lastZeroOffset = 0;
        }
    }
    if (lastZeroOffset != 0) {
c0d0015a:	2b00      	cmp	r3, #0
c0d0015c:	d006      	beq.n	c0d0016c <adjustDecimals+0xe8>
c0d0015e:	2100      	movs	r1, #0
        target[lastZeroOffset] = '\0';
c0d00160:	54e1      	strb	r1, [r4, r3]
        if (target[lastZeroOffset - 1] == '.') {
c0d00162:	1e5a      	subs	r2, r3, #1
c0d00164:	5ca3      	ldrb	r3, [r4, r2]
c0d00166:	2b2e      	cmp	r3, #46	; 0x2e
c0d00168:	d100      	bne.n	c0d0016c <adjustDecimals+0xe8>
            target[lastZeroOffset - 1] = '\0';
c0d0016a:	54a1      	strb	r1, [r4, r2]
        }
    }
    return true;
}
c0d0016c:	b001      	add	sp, #4
c0d0016e:	bdf0      	pop	{r4, r5, r6, r7, pc}

c0d00170 <uint256_to_decimal>:

bool uint256_to_decimal(const uint8_t *value, size_t value_len, char *out, size_t out_len) {
c0d00170:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00172:	b08b      	sub	sp, #44	; 0x2c
    if (value_len > INT256_LENGTH) {
c0d00174:	2920      	cmp	r1, #32
c0d00176:	d901      	bls.n	c0d0017c <uint256_to_decimal+0xc>
c0d00178:	2000      	movs	r0, #0
c0d0017a:	e057      	b.n	c0d0022c <uint256_to_decimal+0xbc>
c0d0017c:	4614      	mov	r4, r2
c0d0017e:	460e      	mov	r6, r1
c0d00180:	4607      	mov	r7, r0
c0d00182:	ad03      	add	r5, sp, #12
c0d00184:	2120      	movs	r1, #32
        // value len is bigger than INT256_LENGTH ?!
        return false;
    }

    uint16_t n[16] = {0};
c0d00186:	4628      	mov	r0, r5
c0d00188:	9302      	str	r3, [sp, #8]
c0d0018a:	f000 fa81 	bl	c0d00690 <__aeabi_memclr>
    // Copy and right-align the number
    memcpy((uint8_t *) n + INT256_LENGTH - value_len, value, value_len);
c0d0018e:	1ba8      	subs	r0, r5, r6
c0d00190:	3020      	adds	r0, #32
c0d00192:	4639      	mov	r1, r7
c0d00194:	4632      	mov	r2, r6
c0d00196:	f000 fa80 	bl	c0d0069a <__aeabi_memcpy>
c0d0019a:	9a02      	ldr	r2, [sp, #8]
c0d0019c:	2000      	movs	r0, #0
c0d0019e:	a903      	add	r1, sp, #12
} txContent_t;

static __attribute__((no_instrument_function)) inline int allzeroes(void *buf, size_t n) {
    uint8_t *p = (uint8_t *) buf;
    for (size_t i = 0; i < n; ++i) {
        if (p[i]) {
c0d001a0:	5c09      	ldrb	r1, [r1, r0]
c0d001a2:	2900      	cmp	r1, #0
c0d001a4:	d10a      	bne.n	c0d001bc <uint256_to_decimal+0x4c>
    for (size_t i = 0; i < n; ++i) {
c0d001a6:	1c40      	adds	r0, r0, #1
c0d001a8:	2820      	cmp	r0, #32
c0d001aa:	d1f8      	bne.n	c0d0019e <uint256_to_decimal+0x2e>

    // Special case when value is 0
    if (allzeroes(n, INT256_LENGTH)) {
        if (out_len < 2) {
c0d001ac:	2a02      	cmp	r2, #2
c0d001ae:	d3e3      	bcc.n	c0d00178 <uint256_to_decimal+0x8>
            // Not enough space to hold "0" and \0.
            return false;
        }
        strlcpy(out, "0", out_len);
c0d001b0:	491f      	ldr	r1, [pc, #124]	; (c0d00230 <uint256_to_decimal+0xc0>)
c0d001b2:	4479      	add	r1, pc
c0d001b4:	4620      	mov	r0, r4
c0d001b6:	f000 fabd 	bl	c0d00734 <strlcpy>
c0d001ba:	e036      	b.n	c0d0022a <uint256_to_decimal+0xba>
c0d001bc:	2000      	movs	r0, #0
c0d001be:	a903      	add	r1, sp, #12
        return true;
    }

    uint16_t *p = n;
    for (int i = 0; i < 16; i++) {
        n[i] = __builtin_bswap16(*p++);
c0d001c0:	5a0b      	ldrh	r3, [r1, r0]
c0d001c2:	ba5b      	rev16	r3, r3
c0d001c4:	520b      	strh	r3, [r1, r0]
    for (int i = 0; i < 16; i++) {
c0d001c6:	1c80      	adds	r0, r0, #2
c0d001c8:	2820      	cmp	r0, #32
c0d001ca:	d1f8      	bne.n	c0d001be <uint256_to_decimal+0x4e>
c0d001cc:	4613      	mov	r3, r2
c0d001ce:	2000      	movs	r0, #0
c0d001d0:	a903      	add	r1, sp, #12
        if (p[i]) {
c0d001d2:	5c09      	ldrb	r1, [r1, r0]
c0d001d4:	2900      	cmp	r1, #0
c0d001d6:	d103      	bne.n	c0d001e0 <uint256_to_decimal+0x70>
    for (size_t i = 0; i < n; ++i) {
c0d001d8:	1c40      	adds	r0, r0, #1
c0d001da:	2820      	cmp	r0, #32
c0d001dc:	d1f8      	bne.n	c0d001d0 <uint256_to_decimal+0x60>
c0d001de:	e01c      	b.n	c0d0021a <uint256_to_decimal+0xaa>
    }
    int pos = out_len;
    while (!allzeroes(n, sizeof(n))) {
        if (pos == 0) {
c0d001e0:	2b00      	cmp	r3, #0
c0d001e2:	d0c9      	beq.n	c0d00178 <uint256_to_decimal+0x8>
c0d001e4:	9300      	str	r3, [sp, #0]
c0d001e6:	9401      	str	r4, [sp, #4]
c0d001e8:	2400      	movs	r4, #0
c0d001ea:	4620      	mov	r0, r4
c0d001ec:	af03      	add	r7, sp, #12
            return false;
        }
        pos -= 1;
        unsigned int carry = 0;
        for (int i = 0; i < 16; i++) {
            int rem = ((carry << 16) | n[i]) % 10;
c0d001ee:	5b39      	ldrh	r1, [r7, r4]
c0d001f0:	0400      	lsls	r0, r0, #16
c0d001f2:	1845      	adds	r5, r0, r1
c0d001f4:	260a      	movs	r6, #10
            n[i] = ((carry << 16) | n[i]) / 10;
c0d001f6:	4628      	mov	r0, r5
c0d001f8:	4631      	mov	r1, r6
c0d001fa:	f000 f9bd 	bl	c0d00578 <__udivsi3>
c0d001fe:	5338      	strh	r0, [r7, r4]
c0d00200:	4346      	muls	r6, r0
c0d00202:	1ba8      	subs	r0, r5, r6
        for (int i = 0; i < 16; i++) {
c0d00204:	1ca4      	adds	r4, r4, #2
c0d00206:	2c20      	cmp	r4, #32
c0d00208:	d1f0      	bne.n	c0d001ec <uint256_to_decimal+0x7c>
c0d0020a:	2130      	movs	r1, #48	; 0x30
            carry = rem;
        }
        out[pos] = '0' + carry;
c0d0020c:	4308      	orrs	r0, r1
c0d0020e:	9b00      	ldr	r3, [sp, #0]
        pos -= 1;
c0d00210:	1e5b      	subs	r3, r3, #1
c0d00212:	9c01      	ldr	r4, [sp, #4]
        out[pos] = '0' + carry;
c0d00214:	54e0      	strb	r0, [r4, r3]
c0d00216:	9a02      	ldr	r2, [sp, #8]
c0d00218:	e7d9      	b.n	c0d001ce <uint256_to_decimal+0x5e>
    }
    memmove(out, out + pos, out_len - pos);
c0d0021a:	18e1      	adds	r1, r4, r3
c0d0021c:	1ad5      	subs	r5, r2, r3
c0d0021e:	4620      	mov	r0, r4
c0d00220:	462a      	mov	r2, r5
c0d00222:	f000 fa3e 	bl	c0d006a2 <__aeabi_memmove>
c0d00226:	2000      	movs	r0, #0
    out[out_len - pos] = 0;
c0d00228:	5560      	strb	r0, [r4, r5]
c0d0022a:	2001      	movs	r0, #1
    return true;
}
c0d0022c:	b00b      	add	sp, #44	; 0x2c
c0d0022e:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00230:	000005fa 	.word	0x000005fa

c0d00234 <amountToString>:
void amountToString(const uint8_t *amount,
                    uint8_t amount_size,
                    uint8_t decimals,
                    const char *ticker,
                    char *out_buffer,
                    uint8_t out_buffer_size) {
c0d00234:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00236:	b09d      	sub	sp, #116	; 0x74
c0d00238:	9303      	str	r3, [sp, #12]
c0d0023a:	9202      	str	r2, [sp, #8]
c0d0023c:	460c      	mov	r4, r1
c0d0023e:	4606      	mov	r6, r0
c0d00240:	af04      	add	r7, sp, #16
c0d00242:	2564      	movs	r5, #100	; 0x64
    char tmp_buffer[100] = {0};
c0d00244:	4638      	mov	r0, r7
c0d00246:	4629      	mov	r1, r5
c0d00248:	f000 fa22 	bl	c0d00690 <__aeabi_memclr>

    if (uint256_to_decimal(amount, amount_size, tmp_buffer, sizeof(tmp_buffer)) == false) {
c0d0024c:	4630      	mov	r0, r6
c0d0024e:	4621      	mov	r1, r4
c0d00250:	463a      	mov	r2, r7
c0d00252:	462b      	mov	r3, r5
c0d00254:	f7ff ff8c 	bl	c0d00170 <uint256_to_decimal>
c0d00258:	2800      	cmp	r0, #0
c0d0025a:	d026      	beq.n	c0d002aa <amountToString+0x76>
c0d0025c:	9d23      	ldr	r5, [sp, #140]	; 0x8c
c0d0025e:	9e22      	ldr	r6, [sp, #136]	; 0x88
c0d00260:	af04      	add	r7, sp, #16
c0d00262:	2164      	movs	r1, #100	; 0x64
        THROW(EXCEPTION_OVERFLOW);
    }

    uint8_t amount_len = strnlen(tmp_buffer, sizeof(tmp_buffer));
c0d00264:	4638      	mov	r0, r7
c0d00266:	f000 fa8b 	bl	c0d00780 <strnlen>
c0d0026a:	9001      	str	r0, [sp, #4]
c0d0026c:	210c      	movs	r1, #12
    uint8_t ticker_len = strnlen(ticker, MAX_TICKER_LEN);
c0d0026e:	9803      	ldr	r0, [sp, #12]
c0d00270:	f000 fa86 	bl	c0d00780 <strnlen>

    memcpy(out_buffer, ticker, MIN(out_buffer_size, ticker_len));
c0d00274:	b2c4      	uxtb	r4, r0
c0d00276:	42ac      	cmp	r4, r5
c0d00278:	462a      	mov	r2, r5
c0d0027a:	d800      	bhi.n	c0d0027e <amountToString+0x4a>
c0d0027c:	4622      	mov	r2, r4
c0d0027e:	4630      	mov	r0, r6
c0d00280:	9903      	ldr	r1, [sp, #12]
c0d00282:	f000 fa0a 	bl	c0d0069a <__aeabi_memcpy>

    if (adjustDecimals(tmp_buffer,
c0d00286:	9802      	ldr	r0, [sp, #8]
c0d00288:	9000      	str	r0, [sp, #0]
                       amount_len,
                       out_buffer + ticker_len,
c0d0028a:	1932      	adds	r2, r6, r4
                       out_buffer_size - ticker_len - 1,
c0d0028c:	43e0      	mvns	r0, r4
c0d0028e:	1943      	adds	r3, r0, r5
                       amount_len,
c0d00290:	9801      	ldr	r0, [sp, #4]
c0d00292:	b2c1      	uxtb	r1, r0
    if (adjustDecimals(tmp_buffer,
c0d00294:	4638      	mov	r0, r7
c0d00296:	f7ff fef5 	bl	c0d00084 <adjustDecimals>
c0d0029a:	2800      	cmp	r0, #0
c0d0029c:	d005      	beq.n	c0d002aa <amountToString+0x76>
                       decimals) == false) {
        THROW(EXCEPTION_OVERFLOW);
    }

    out_buffer[out_buffer_size - 1] = '\0';
c0d0029e:	19a8      	adds	r0, r5, r6
c0d002a0:	1e40      	subs	r0, r0, #1
c0d002a2:	2100      	movs	r1, #0
c0d002a4:	7001      	strb	r1, [r0, #0]
}
c0d002a6:	b01d      	add	sp, #116	; 0x74
c0d002a8:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d002aa:	2007      	movs	r0, #7
c0d002ac:	f000 f8f0 	bl	c0d00490 <os_longjmp>

c0d002b0 <handle_finalize>:
#include "ricochet_plugin.h"

void handle_finalize(void *parameters) {
c0d002b0:	2104      	movs	r1, #4
    context_t *context = (context_t *) msg->pluginContext;

    msg->uiType = ETH_UI_TYPE_GENERIC;

    msg->numScreens = 2;
    msg->result = ETH_PLUGIN_RESULT_OK;
c0d002b2:	7781      	strb	r1, [r0, #30]
c0d002b4:	4901      	ldr	r1, [pc, #4]	; (c0d002bc <handle_finalize+0xc>)
    msg->uiType = ETH_UI_TYPE_GENERIC;
c0d002b6:	8381      	strh	r1, [r0, #28]
}
c0d002b8:	4770      	bx	lr
c0d002ba:	46c0      	nop			; (mov r8, r8)
c0d002bc:	00000202 	.word	0x00000202

c0d002c0 <handle_init_contract>:
#include "ricochet_plugin.h"

// Called once to init.
void handle_init_contract(void *parameters) {
c0d002c0:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d002c2:	b081      	sub	sp, #4
c0d002c4:	4604      	mov	r4, r0
    ethPluginInitContract_t *msg = (ethPluginInitContract_t *) parameters;

    if (msg->interfaceVersion != ETH_PLUGIN_INTERFACE_VERSION_LATEST) {
c0d002c6:	7800      	ldrb	r0, [r0, #0]
c0d002c8:	2803      	cmp	r0, #3
c0d002ca:	d12c      	bne.n	c0d00326 <handle_init_contract+0x66>
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
        return;
    }

    if (msg->pluginContextLength < sizeof(context_t)) {
c0d002cc:	6920      	ldr	r0, [r4, #16]
c0d002ce:	282a      	cmp	r0, #42	; 0x2a
c0d002d0:	d336      	bcc.n	c0d00340 <handle_init_contract+0x80>
        PRINTF("Plugin parameters structure is bigger than allowed size\n");
        // msg->result = ETH_PLUGIN_RESULT_ERROR;
        return;
    }

    context_t *context = (context_t *) msg->pluginContext;
c0d002d2:	68e5      	ldr	r5, [r4, #12]
c0d002d4:	212a      	movs	r1, #42	; 0x2a

    memset(context, 0, sizeof(*context));
c0d002d6:	4628      	mov	r0, r5
c0d002d8:	f000 f9da 	bl	c0d00690 <__aeabi_memclr>
c0d002dc:	3526      	adds	r5, #38	; 0x26
c0d002de:	2000      	movs	r0, #0
c0d002e0:	4e18      	ldr	r6, [pc, #96]	; (c0d00344 <handle_init_contract+0x84>)
c0d002e2:	447e      	add	r6, pc

    uint8_t i;
    for (i = 0; i < NUM_SELECTORS; i++) {
c0d002e4:	2801      	cmp	r0, #1
c0d002e6:	d020      	beq.n	c0d0032a <handle_init_contract+0x6a>
c0d002e8:	4607      	mov	r7, r0
        if (memcmp((uint8_t *) PIC(RICOCHET_SELECTORS[i]), msg->selector, SELECTOR_SIZE) == 0) {
c0d002ea:	0080      	lsls	r0, r0, #2
c0d002ec:	5830      	ldr	r0, [r6, r0]
c0d002ee:	f000 f8d5 	bl	c0d0049c <pic>
c0d002f2:	7801      	ldrb	r1, [r0, #0]
c0d002f4:	7842      	ldrb	r2, [r0, #1]
c0d002f6:	0212      	lsls	r2, r2, #8
c0d002f8:	1851      	adds	r1, r2, r1
c0d002fa:	7882      	ldrb	r2, [r0, #2]
c0d002fc:	78c0      	ldrb	r0, [r0, #3]
c0d002fe:	0200      	lsls	r0, r0, #8
c0d00300:	1880      	adds	r0, r0, r2
c0d00302:	0400      	lsls	r0, r0, #16
c0d00304:	1841      	adds	r1, r0, r1
c0d00306:	6960      	ldr	r0, [r4, #20]
c0d00308:	7802      	ldrb	r2, [r0, #0]
c0d0030a:	7843      	ldrb	r3, [r0, #1]
c0d0030c:	021b      	lsls	r3, r3, #8
c0d0030e:	189a      	adds	r2, r3, r2
c0d00310:	7883      	ldrb	r3, [r0, #2]
c0d00312:	78c0      	ldrb	r0, [r0, #3]
c0d00314:	0200      	lsls	r0, r0, #8
c0d00316:	18c0      	adds	r0, r0, r3
c0d00318:	0400      	lsls	r0, r0, #16
c0d0031a:	1882      	adds	r2, r0, r2
c0d0031c:	2001      	movs	r0, #1
c0d0031e:	4291      	cmp	r1, r2
c0d00320:	d1e0      	bne.n	c0d002e4 <handle_init_contract+0x24>
            context->selectorIndex = i;
c0d00322:	70af      	strb	r7, [r5, #2]
c0d00324:	e008      	b.n	c0d00338 <handle_init_contract+0x78>
c0d00326:	2001      	movs	r0, #1
c0d00328:	e009      	b.n	c0d0033e <handle_init_contract+0x7e>
c0d0032a:	2001      	movs	r0, #1
            break;
        }
    }
    if (i == NUM_SELECTORS) {
        msg->result = ETH_PLUGIN_RESULT_UNAVAILABLE;
c0d0032c:	7060      	strb	r0, [r4, #1]
    }

    // Set `next_param` to be the first field we expect to parse.
    switch (context->selectorIndex) {
c0d0032e:	78a8      	ldrb	r0, [r5, #2]
c0d00330:	2800      	cmp	r0, #0
c0d00332:	d001      	beq.n	c0d00338 <handle_init_contract+0x78>
c0d00334:	2000      	movs	r0, #0
c0d00336:	e002      	b.n	c0d0033e <handle_init_contract+0x7e>
c0d00338:	2000      	movs	r0, #0
        case UPGRADE:
            context->next_param = AMOUNT;
c0d0033a:	7028      	strb	r0, [r5, #0]
c0d0033c:	2004      	movs	r0, #4
c0d0033e:	7060      	strb	r0, [r4, #1]
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }

    msg->result = ETH_PLUGIN_RESULT_OK;
}
c0d00340:	b001      	add	sp, #4
c0d00342:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d00344:	000004ea 	.word	0x000004ea

c0d00348 <handle_provide_parameter>:
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            break;
    }
}

void handle_provide_parameter(void *parameters) {
c0d00348:	b510      	push	{r4, lr}
c0d0034a:	2104      	movs	r1, #4
    ethPluginProvideParameter_t *msg = (ethPluginProvideParameter_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;

    msg->result = ETH_PLUGIN_RESULT_OK;
c0d0034c:	7501      	strb	r1, [r0, #20]
    context_t *context = (context_t *) msg->pluginContext;
c0d0034e:	6881      	ldr	r1, [r0, #8]
c0d00350:	2224      	movs	r2, #36	; 0x24

    if (context->skip) {
c0d00352:	5c8a      	ldrb	r2, [r1, r2]
c0d00354:	460c      	mov	r4, r1
c0d00356:	3424      	adds	r4, #36	; 0x24
c0d00358:	2a00      	cmp	r2, #0
c0d0035a:	d002      	beq.n	c0d00362 <handle_provide_parameter+0x1a>
        // Skip this step, and don't forget to decrease skipping counter.
        context->skip--;
c0d0035c:	1e50      	subs	r0, r2, #1
c0d0035e:	7020      	strb	r0, [r4, #0]
                PRINTF("Selector Index not supported: %d\n", context->selectorIndex);
                msg->result = ETH_PLUGIN_RESULT_ERROR;
                break;
        }
    }
}
c0d00360:	bd10      	pop	{r4, pc}
        if ((context->offset) && msg->parameterOffset != context->checkpoint + context->offset) {
c0d00362:	8c0a      	ldrh	r2, [r1, #32]
c0d00364:	2a00      	cmp	r2, #0
c0d00366:	d004      	beq.n	c0d00372 <handle_provide_parameter+0x2a>
c0d00368:	8c4b      	ldrh	r3, [r1, #34]	; 0x22
c0d0036a:	189a      	adds	r2, r3, r2
c0d0036c:	6903      	ldr	r3, [r0, #16]
c0d0036e:	4293      	cmp	r3, r2
c0d00370:	d105      	bne.n	c0d0037e <handle_provide_parameter+0x36>
c0d00372:	2200      	movs	r2, #0
        context->offset = 0;  // Reset offset
c0d00374:	840a      	strh	r2, [r1, #32]
        switch (context->selectorIndex) {
c0d00376:	7923      	ldrb	r3, [r4, #4]
c0d00378:	2b00      	cmp	r3, #0
c0d0037a:	d001      	beq.n	c0d00380 <handle_provide_parameter+0x38>
c0d0037c:	7502      	strb	r2, [r0, #20]
}
c0d0037e:	bd10      	pop	{r4, pc}
    switch (context->next_param) {
c0d00380:	78a3      	ldrb	r3, [r4, #2]
c0d00382:	2b01      	cmp	r3, #1
c0d00384:	d0fb      	beq.n	c0d0037e <handle_provide_parameter+0x36>
c0d00386:	2b00      	cmp	r3, #0
c0d00388:	d1f8      	bne.n	c0d0037c <handle_provide_parameter+0x34>
c0d0038a:	2220      	movs	r2, #32
    memcpy(dst, src, PARAMETER_LENGTH);
c0d0038c:	4608      	mov	r0, r1
c0d0038e:	4611      	mov	r1, r2
c0d00390:	f000 f983 	bl	c0d0069a <__aeabi_memcpy>
c0d00394:	2001      	movs	r0, #1
            context->next_param = NONE;
c0d00396:	70a0      	strb	r0, [r4, #2]
}
c0d00398:	bd10      	pop	{r4, pc}
	...

c0d0039c <handle_query_contract_id>:
#include "ricochet_plugin.h"

void handle_query_contract_id(void *parameters) {
c0d0039c:	b5b0      	push	{r4, r5, r7, lr}
c0d0039e:	4604      	mov	r4, r0
    ethQueryContractID_t *msg = (ethQueryContractID_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;
c0d003a0:	6885      	ldr	r5, [r0, #8]

    strlcpy(msg->name, PLUGIN_NAME, msg->nameLength);
c0d003a2:	68c0      	ldr	r0, [r0, #12]
c0d003a4:	6922      	ldr	r2, [r4, #16]
c0d003a6:	4909      	ldr	r1, [pc, #36]	; (c0d003cc <handle_query_contract_id+0x30>)
c0d003a8:	4479      	add	r1, pc
c0d003aa:	f000 f9c3 	bl	c0d00734 <strlcpy>
c0d003ae:	2028      	movs	r0, #40	; 0x28

    switch (context->selectorIndex) {
c0d003b0:	5c28      	ldrb	r0, [r5, r0]
c0d003b2:	2800      	cmp	r0, #0
c0d003b4:	d001      	beq.n	c0d003ba <handle_query_contract_id+0x1e>
c0d003b6:	2000      	movs	r0, #0
c0d003b8:	e006      	b.n	c0d003c8 <handle_query_contract_id+0x2c>
        case UPGRADE:
            strlcpy(msg->version, "Updrage", msg->versionLength);
c0d003ba:	6960      	ldr	r0, [r4, #20]
c0d003bc:	69a2      	ldr	r2, [r4, #24]
c0d003be:	4904      	ldr	r1, [pc, #16]	; (c0d003d0 <handle_query_contract_id+0x34>)
c0d003c0:	4479      	add	r1, pc
c0d003c2:	f000 f9b7 	bl	c0d00734 <strlcpy>
c0d003c6:	2004      	movs	r0, #4
        default:
            PRINTF("Selector index: %d not supported\n", context->selectorIndex);
            msg->result = ETH_PLUGIN_RESULT_ERROR;
            return;
    }
    msg->result = ETH_PLUGIN_RESULT_OK;
c0d003c8:	7720      	strb	r0, [r4, #28]
c0d003ca:	bdb0      	pop	{r4, r5, r7, pc}
c0d003cc:	00000406 	.word	0x00000406
c0d003d0:	000003f7 	.word	0x000003f7

c0d003d4 <handle_query_contract_ui>:
            return ERROR;
            break;
    }
}

void handle_query_contract_ui(void *parameters) {
c0d003d4:	b5b0      	push	{r4, r5, r7, lr}
c0d003d6:	b082      	sub	sp, #8
c0d003d8:	4605      	mov	r5, r0
    ethQueryContractUI_t *msg = (ethQueryContractUI_t *) parameters;
    context_t *context = (context_t *) msg->pluginContext;
c0d003da:	6884      	ldr	r4, [r0, #8]

    memset(msg->title, 0, msg->titleLength);
c0d003dc:	69c0      	ldr	r0, [r0, #28]
c0d003de:	6a29      	ldr	r1, [r5, #32]
c0d003e0:	f000 f956 	bl	c0d00690 <__aeabi_memclr>
    memset(msg->msg, 0, msg->msgLength);
c0d003e4:	6a68      	ldr	r0, [r5, #36]	; 0x24
c0d003e6:	6aa9      	ldr	r1, [r5, #40]	; 0x28
c0d003e8:	f000 f952 	bl	c0d00690 <__aeabi_memclr>
c0d003ec:	202c      	movs	r0, #44	; 0x2c
c0d003ee:	2104      	movs	r1, #4
    msg->result = ETH_PLUGIN_RESULT_OK;
c0d003f0:	5429      	strb	r1, [r5, r0]
    uint8_t index = msg->screenIndex;
c0d003f2:	7b28      	ldrb	r0, [r5, #12]

    screens_t screen = get_screen(msg, context);

    switch (screen) {
c0d003f4:	2800      	cmp	r0, #0
c0d003f6:	d003      	beq.n	c0d00400 <handle_query_contract_ui+0x2c>
c0d003f8:	352c      	adds	r5, #44	; 0x2c
c0d003fa:	2000      	movs	r0, #0
        case AMOUNT_SCREEN:
            set_amount_ui(msg, context);
            break;
        default:
            PRINTF("Received an invalid screenIndex\n");
            msg->result = ETH_PLUGIN_RESULT_ERROR;
c0d003fc:	7028      	strb	r0, [r5, #0]
c0d003fe:	e011      	b.n	c0d00424 <handle_query_contract_ui+0x50>
    strlcpy(msg->title, "Amount", msg->titleLength);
c0d00400:	69e8      	ldr	r0, [r5, #28]
c0d00402:	6a2a      	ldr	r2, [r5, #32]
c0d00404:	4908      	ldr	r1, [pc, #32]	; (c0d00428 <handle_query_contract_ui+0x54>)
c0d00406:	4479      	add	r1, pc
c0d00408:	f000 f994 	bl	c0d00734 <strlcpy>
c0d0040c:	2028      	movs	r0, #40	; 0x28
    amountToString(context->amount, sizeof(context->amount), 0, "", msg->msg, msg->msgLength);
c0d0040e:	5c28      	ldrb	r0, [r5, r0]
c0d00410:	6a69      	ldr	r1, [r5, #36]	; 0x24
c0d00412:	9100      	str	r1, [sp, #0]
c0d00414:	9001      	str	r0, [sp, #4]
c0d00416:	2120      	movs	r1, #32
c0d00418:	2200      	movs	r2, #0
c0d0041a:	4b04      	ldr	r3, [pc, #16]	; (c0d0042c <handle_query_contract_ui+0x58>)
c0d0041c:	447b      	add	r3, pc
c0d0041e:	4620      	mov	r0, r4
c0d00420:	f7ff ff08 	bl	c0d00234 <amountToString>
            return;
    }
}
c0d00424:	b002      	add	sp, #8
c0d00426:	bdb0      	pop	{r4, r5, r7, pc}
c0d00428:	000003b9 	.word	0x000003b9
c0d0042c:	00000391 	.word	0x00000391

c0d00430 <dispatch_plugin_calls>:
void dispatch_plugin_calls(int message, void *parameters) {
c0d00430:	b580      	push	{r7, lr}
c0d00432:	2281      	movs	r2, #129	; 0x81
c0d00434:	0052      	lsls	r2, r2, #1
    switch (message) {
c0d00436:	4290      	cmp	r0, r2
c0d00438:	dd0f      	ble.n	c0d0045a <dispatch_plugin_calls+0x2a>
c0d0043a:	22ff      	movs	r2, #255	; 0xff
c0d0043c:	4613      	mov	r3, r2
c0d0043e:	3304      	adds	r3, #4
c0d00440:	4298      	cmp	r0, r3
c0d00442:	d014      	beq.n	c0d0046e <dispatch_plugin_calls+0x3e>
c0d00444:	3206      	adds	r2, #6
c0d00446:	4290      	cmp	r0, r2
c0d00448:	d015      	beq.n	c0d00476 <dispatch_plugin_calls+0x46>
c0d0044a:	2283      	movs	r2, #131	; 0x83
c0d0044c:	0052      	lsls	r2, r2, #1
c0d0044e:	4290      	cmp	r0, r2
c0d00450:	d114      	bne.n	c0d0047c <dispatch_plugin_calls+0x4c>
            handle_query_contract_ui(parameters);
c0d00452:	4608      	mov	r0, r1
c0d00454:	f7ff ffbe 	bl	c0d003d4 <handle_query_contract_ui>
}
c0d00458:	bd80      	pop	{r7, pc}
c0d0045a:	23ff      	movs	r3, #255	; 0xff
c0d0045c:	3302      	adds	r3, #2
    switch (message) {
c0d0045e:	4298      	cmp	r0, r3
c0d00460:	d00d      	beq.n	c0d0047e <dispatch_plugin_calls+0x4e>
c0d00462:	4290      	cmp	r0, r2
c0d00464:	d10a      	bne.n	c0d0047c <dispatch_plugin_calls+0x4c>
            handle_provide_parameter(parameters);
c0d00466:	4608      	mov	r0, r1
c0d00468:	f7ff ff6e 	bl	c0d00348 <handle_provide_parameter>
}
c0d0046c:	bd80      	pop	{r7, pc}
            handle_finalize(parameters);
c0d0046e:	4608      	mov	r0, r1
c0d00470:	f7ff ff1e 	bl	c0d002b0 <handle_finalize>
}
c0d00474:	bd80      	pop	{r7, pc}
            handle_query_contract_id(parameters);
c0d00476:	4608      	mov	r0, r1
c0d00478:	f7ff ff90 	bl	c0d0039c <handle_query_contract_id>
}
c0d0047c:	bd80      	pop	{r7, pc}
            handle_init_contract(parameters);
c0d0047e:	4608      	mov	r0, r1
c0d00480:	f7ff ff1e 	bl	c0d002c0 <handle_init_contract>
}
c0d00484:	bd80      	pop	{r7, pc}

c0d00486 <os_boot>:

// apdu buffer must hold a complete apdu to avoid troubles
unsigned char G_io_apdu_buffer[IO_APDU_BUFFER_SIZE];

#ifndef BOLOS_OS_UPGRADER_APP
void os_boot(void) {
c0d00486:	b580      	push	{r7, lr}
c0d00488:	2000      	movs	r0, #0
  // // TODO patch entry point when romming (f)
  // // set the default try context to nothing
#ifndef HAVE_BOLOS
  try_context_set(NULL);
c0d0048a:	f000 f867 	bl	c0d0055c <try_context_set>
#endif // HAVE_BOLOS
}
c0d0048e:	bd80      	pop	{r7, pc}

c0d00490 <os_longjmp>:
  }
  return xoracc;
}

#ifndef HAVE_BOLOS
void os_longjmp(unsigned int exception) {
c0d00490:	4604      	mov	r4, r0
#ifdef HAVE_PRINTF  
  unsigned int lr_val;
  __asm volatile("mov %0, lr" :"=r"(lr_val));
  PRINTF("exception[%d]: LR=0x%08X\n", exception, lr_val);
#endif // HAVE_PRINTF
  longjmp(try_context_get()->jmp_buf, exception);
c0d00492:	f000 f857 	bl	c0d00544 <try_context_get>
c0d00496:	4621      	mov	r1, r4
c0d00498:	f000 f93e 	bl	c0d00718 <longjmp>

c0d0049c <pic>:
// only apply PIC conversion if link_address is in linked code (over 0xC0D00000 in our example)
// this way, PIC call are armless if the address is not meant to be converted
extern void _nvram;
extern void _envram;

void *pic(void *link_address) {
c0d0049c:	b580      	push	{r7, lr}
  if (link_address >= &_nvram && link_address < &_envram) {
c0d0049e:	4904      	ldr	r1, [pc, #16]	; (c0d004b0 <pic+0x14>)
c0d004a0:	4288      	cmp	r0, r1
c0d004a2:	d304      	bcc.n	c0d004ae <pic+0x12>
c0d004a4:	4903      	ldr	r1, [pc, #12]	; (c0d004b4 <pic+0x18>)
c0d004a6:	4288      	cmp	r0, r1
c0d004a8:	d201      	bcs.n	c0d004ae <pic+0x12>
    link_address = pic_internal(link_address);
c0d004aa:	f000 f805 	bl	c0d004b8 <pic_internal>
  }
  return link_address;
c0d004ae:	bd80      	pop	{r7, pc}
c0d004b0:	c0d00000 	.word	0xc0d00000
c0d004b4:	c0d00800 	.word	0xc0d00800

c0d004b8 <pic_internal>:
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
__attribute__((naked)) void *pic_internal(void *link_address)
{
  // compute the delta offset between LinkMemAddr & ExecMemAddr
  __asm volatile ("mov r2, pc\n");
c0d004b8:	467a      	mov	r2, pc
  __asm volatile ("ldr r1, =pic_internal\n");
c0d004ba:	4902      	ldr	r1, [pc, #8]	; (c0d004c4 <pic_internal+0xc>)
  __asm volatile ("adds r1, r1, #3\n");
c0d004bc:	1cc9      	adds	r1, r1, #3
  __asm volatile ("subs r1, r1, r2\n");
c0d004be:	1a89      	subs	r1, r1, r2

  // adjust value of the given parameter
  __asm volatile ("subs r0, r0, r1\n");
c0d004c0:	1a40      	subs	r0, r0, r1
  __asm volatile ("bx lr\n");
c0d004c2:	4770      	bx	lr
c0d004c4:	c0d004b9 	.word	0xc0d004b9

c0d004c8 <SVC_Call>:
.thumb
.thumb_func
.global SVC_Call

SVC_Call:
    svc 1
c0d004c8:	df01      	svc	1
    cmp r1, #0
c0d004ca:	2900      	cmp	r1, #0
    bne exception
c0d004cc:	d100      	bne.n	c0d004d0 <exception>
    bx lr
c0d004ce:	4770      	bx	lr

c0d004d0 <exception>:
exception:
    // THROW(ex);
    mov r0, r1
c0d004d0:	4608      	mov	r0, r1
    bl os_longjmp
c0d004d2:	f7ff ffdd 	bl	c0d00490 <os_longjmp>
	...

c0d004d8 <get_api_level>:
#include <string.h>

unsigned int SVC_Call(unsigned int syscall_id, void *parameters);
unsigned int SVC_cx_call(unsigned int syscall_id, unsigned int * parameters);

unsigned int get_api_level(void) {
c0d004d8:	b580      	push	{r7, lr}
c0d004da:	b084      	sub	sp, #16
c0d004dc:	2000      	movs	r0, #0
  unsigned int parameters [2+1];
  parameters[0] = 0;
  parameters[1] = 0;
c0d004de:	9002      	str	r0, [sp, #8]
  parameters[0] = 0;
c0d004e0:	9001      	str	r0, [sp, #4]
c0d004e2:	4803      	ldr	r0, [pc, #12]	; (c0d004f0 <get_api_level+0x18>)
c0d004e4:	a901      	add	r1, sp, #4
  return SVC_Call(SYSCALL_get_api_level_ID_IN, parameters);
c0d004e6:	f7ff ffef 	bl	c0d004c8 <SVC_Call>
c0d004ea:	b004      	add	sp, #16
c0d004ec:	bd80      	pop	{r7, pc}
c0d004ee:	46c0      	nop			; (mov r8, r8)
c0d004f0:	60000138 	.word	0x60000138

c0d004f4 <os_lib_call>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_ux_result_ID_IN, parameters);
  return;
}

void os_lib_call ( unsigned int * call_parameters ) {
c0d004f4:	b580      	push	{r7, lr}
c0d004f6:	b084      	sub	sp, #16
c0d004f8:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)call_parameters;
  parameters[1] = 0;
c0d004fa:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)call_parameters;
c0d004fc:	9001      	str	r0, [sp, #4]
c0d004fe:	4803      	ldr	r0, [pc, #12]	; (c0d0050c <os_lib_call+0x18>)
c0d00500:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_lib_call_ID_IN, parameters);
c0d00502:	f7ff ffe1 	bl	c0d004c8 <SVC_Call>
  return;
}
c0d00506:	b004      	add	sp, #16
c0d00508:	bd80      	pop	{r7, pc}
c0d0050a:	46c0      	nop			; (mov r8, r8)
c0d0050c:	6000670d 	.word	0x6000670d

c0d00510 <os_lib_end>:

void os_lib_end ( void ) {
c0d00510:	b580      	push	{r7, lr}
c0d00512:	b082      	sub	sp, #8
c0d00514:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d00516:	9001      	str	r0, [sp, #4]
c0d00518:	4802      	ldr	r0, [pc, #8]	; (c0d00524 <os_lib_end+0x14>)
c0d0051a:	4669      	mov	r1, sp
  SVC_Call(SYSCALL_os_lib_end_ID_IN, parameters);
c0d0051c:	f7ff ffd4 	bl	c0d004c8 <SVC_Call>
  return;
}
c0d00520:	b002      	add	sp, #8
c0d00522:	bd80      	pop	{r7, pc}
c0d00524:	6000688d 	.word	0x6000688d

c0d00528 <os_sched_exit>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_os_sched_exec_ID_IN, parameters);
  return;
}

void os_sched_exit ( bolos_task_status_t exit_code ) {
c0d00528:	b580      	push	{r7, lr}
c0d0052a:	b084      	sub	sp, #16
c0d0052c:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)exit_code;
  parameters[1] = 0;
c0d0052e:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)exit_code;
c0d00530:	9001      	str	r0, [sp, #4]
c0d00532:	4803      	ldr	r0, [pc, #12]	; (c0d00540 <os_sched_exit+0x18>)
c0d00534:	a901      	add	r1, sp, #4
  SVC_Call(SYSCALL_os_sched_exit_ID_IN, parameters);
c0d00536:	f7ff ffc7 	bl	c0d004c8 <SVC_Call>
  return;
}
c0d0053a:	b004      	add	sp, #16
c0d0053c:	bd80      	pop	{r7, pc}
c0d0053e:	46c0      	nop			; (mov r8, r8)
c0d00540:	60009abe 	.word	0x60009abe

c0d00544 <try_context_get>:
  parameters[1] = 0;
  SVC_Call(SYSCALL_nvm_erase_page_ID_IN, parameters);
  return;
}

try_context_t * try_context_get ( void ) {
c0d00544:	b580      	push	{r7, lr}
c0d00546:	b082      	sub	sp, #8
c0d00548:	2000      	movs	r0, #0
  unsigned int parameters [2];
  parameters[1] = 0;
c0d0054a:	9001      	str	r0, [sp, #4]
c0d0054c:	4802      	ldr	r0, [pc, #8]	; (c0d00558 <try_context_get+0x14>)
c0d0054e:	4669      	mov	r1, sp
  return (try_context_t *) SVC_Call(SYSCALL_try_context_get_ID_IN, parameters);
c0d00550:	f7ff ffba 	bl	c0d004c8 <SVC_Call>
c0d00554:	b002      	add	sp, #8
c0d00556:	bd80      	pop	{r7, pc}
c0d00558:	600087b1 	.word	0x600087b1

c0d0055c <try_context_set>:
}

try_context_t * try_context_set ( try_context_t *context ) {
c0d0055c:	b580      	push	{r7, lr}
c0d0055e:	b084      	sub	sp, #16
c0d00560:	2100      	movs	r1, #0
  unsigned int parameters [2+1];
  parameters[0] = (unsigned int)context;
  parameters[1] = 0;
c0d00562:	9102      	str	r1, [sp, #8]
  parameters[0] = (unsigned int)context;
c0d00564:	9001      	str	r0, [sp, #4]
c0d00566:	4803      	ldr	r0, [pc, #12]	; (c0d00574 <try_context_set+0x18>)
c0d00568:	a901      	add	r1, sp, #4
  return (try_context_t *) SVC_Call(SYSCALL_try_context_set_ID_IN, parameters);
c0d0056a:	f7ff ffad 	bl	c0d004c8 <SVC_Call>
c0d0056e:	b004      	add	sp, #16
c0d00570:	bd80      	pop	{r7, pc}
c0d00572:	46c0      	nop			; (mov r8, r8)
c0d00574:	60010b06 	.word	0x60010b06

c0d00578 <__udivsi3>:
c0d00578:	2200      	movs	r2, #0
c0d0057a:	0843      	lsrs	r3, r0, #1
c0d0057c:	428b      	cmp	r3, r1
c0d0057e:	d374      	bcc.n	c0d0066a <__udivsi3+0xf2>
c0d00580:	0903      	lsrs	r3, r0, #4
c0d00582:	428b      	cmp	r3, r1
c0d00584:	d35f      	bcc.n	c0d00646 <__udivsi3+0xce>
c0d00586:	0a03      	lsrs	r3, r0, #8
c0d00588:	428b      	cmp	r3, r1
c0d0058a:	d344      	bcc.n	c0d00616 <__udivsi3+0x9e>
c0d0058c:	0b03      	lsrs	r3, r0, #12
c0d0058e:	428b      	cmp	r3, r1
c0d00590:	d328      	bcc.n	c0d005e4 <__udivsi3+0x6c>
c0d00592:	0c03      	lsrs	r3, r0, #16
c0d00594:	428b      	cmp	r3, r1
c0d00596:	d30d      	bcc.n	c0d005b4 <__udivsi3+0x3c>
c0d00598:	22ff      	movs	r2, #255	; 0xff
c0d0059a:	0209      	lsls	r1, r1, #8
c0d0059c:	ba12      	rev	r2, r2
c0d0059e:	0c03      	lsrs	r3, r0, #16
c0d005a0:	428b      	cmp	r3, r1
c0d005a2:	d302      	bcc.n	c0d005aa <__udivsi3+0x32>
c0d005a4:	1212      	asrs	r2, r2, #8
c0d005a6:	0209      	lsls	r1, r1, #8
c0d005a8:	d065      	beq.n	c0d00676 <__udivsi3+0xfe>
c0d005aa:	0b03      	lsrs	r3, r0, #12
c0d005ac:	428b      	cmp	r3, r1
c0d005ae:	d319      	bcc.n	c0d005e4 <__udivsi3+0x6c>
c0d005b0:	e000      	b.n	c0d005b4 <__udivsi3+0x3c>
c0d005b2:	0a09      	lsrs	r1, r1, #8
c0d005b4:	0bc3      	lsrs	r3, r0, #15
c0d005b6:	428b      	cmp	r3, r1
c0d005b8:	d301      	bcc.n	c0d005be <__udivsi3+0x46>
c0d005ba:	03cb      	lsls	r3, r1, #15
c0d005bc:	1ac0      	subs	r0, r0, r3
c0d005be:	4152      	adcs	r2, r2
c0d005c0:	0b83      	lsrs	r3, r0, #14
c0d005c2:	428b      	cmp	r3, r1
c0d005c4:	d301      	bcc.n	c0d005ca <__udivsi3+0x52>
c0d005c6:	038b      	lsls	r3, r1, #14
c0d005c8:	1ac0      	subs	r0, r0, r3
c0d005ca:	4152      	adcs	r2, r2
c0d005cc:	0b43      	lsrs	r3, r0, #13
c0d005ce:	428b      	cmp	r3, r1
c0d005d0:	d301      	bcc.n	c0d005d6 <__udivsi3+0x5e>
c0d005d2:	034b      	lsls	r3, r1, #13
c0d005d4:	1ac0      	subs	r0, r0, r3
c0d005d6:	4152      	adcs	r2, r2
c0d005d8:	0b03      	lsrs	r3, r0, #12
c0d005da:	428b      	cmp	r3, r1
c0d005dc:	d301      	bcc.n	c0d005e2 <__udivsi3+0x6a>
c0d005de:	030b      	lsls	r3, r1, #12
c0d005e0:	1ac0      	subs	r0, r0, r3
c0d005e2:	4152      	adcs	r2, r2
c0d005e4:	0ac3      	lsrs	r3, r0, #11
c0d005e6:	428b      	cmp	r3, r1
c0d005e8:	d301      	bcc.n	c0d005ee <__udivsi3+0x76>
c0d005ea:	02cb      	lsls	r3, r1, #11
c0d005ec:	1ac0      	subs	r0, r0, r3
c0d005ee:	4152      	adcs	r2, r2
c0d005f0:	0a83      	lsrs	r3, r0, #10
c0d005f2:	428b      	cmp	r3, r1
c0d005f4:	d301      	bcc.n	c0d005fa <__udivsi3+0x82>
c0d005f6:	028b      	lsls	r3, r1, #10
c0d005f8:	1ac0      	subs	r0, r0, r3
c0d005fa:	4152      	adcs	r2, r2
c0d005fc:	0a43      	lsrs	r3, r0, #9
c0d005fe:	428b      	cmp	r3, r1
c0d00600:	d301      	bcc.n	c0d00606 <__udivsi3+0x8e>
c0d00602:	024b      	lsls	r3, r1, #9
c0d00604:	1ac0      	subs	r0, r0, r3
c0d00606:	4152      	adcs	r2, r2
c0d00608:	0a03      	lsrs	r3, r0, #8
c0d0060a:	428b      	cmp	r3, r1
c0d0060c:	d301      	bcc.n	c0d00612 <__udivsi3+0x9a>
c0d0060e:	020b      	lsls	r3, r1, #8
c0d00610:	1ac0      	subs	r0, r0, r3
c0d00612:	4152      	adcs	r2, r2
c0d00614:	d2cd      	bcs.n	c0d005b2 <__udivsi3+0x3a>
c0d00616:	09c3      	lsrs	r3, r0, #7
c0d00618:	428b      	cmp	r3, r1
c0d0061a:	d301      	bcc.n	c0d00620 <__udivsi3+0xa8>
c0d0061c:	01cb      	lsls	r3, r1, #7
c0d0061e:	1ac0      	subs	r0, r0, r3
c0d00620:	4152      	adcs	r2, r2
c0d00622:	0983      	lsrs	r3, r0, #6
c0d00624:	428b      	cmp	r3, r1
c0d00626:	d301      	bcc.n	c0d0062c <__udivsi3+0xb4>
c0d00628:	018b      	lsls	r3, r1, #6
c0d0062a:	1ac0      	subs	r0, r0, r3
c0d0062c:	4152      	adcs	r2, r2
c0d0062e:	0943      	lsrs	r3, r0, #5
c0d00630:	428b      	cmp	r3, r1
c0d00632:	d301      	bcc.n	c0d00638 <__udivsi3+0xc0>
c0d00634:	014b      	lsls	r3, r1, #5
c0d00636:	1ac0      	subs	r0, r0, r3
c0d00638:	4152      	adcs	r2, r2
c0d0063a:	0903      	lsrs	r3, r0, #4
c0d0063c:	428b      	cmp	r3, r1
c0d0063e:	d301      	bcc.n	c0d00644 <__udivsi3+0xcc>
c0d00640:	010b      	lsls	r3, r1, #4
c0d00642:	1ac0      	subs	r0, r0, r3
c0d00644:	4152      	adcs	r2, r2
c0d00646:	08c3      	lsrs	r3, r0, #3
c0d00648:	428b      	cmp	r3, r1
c0d0064a:	d301      	bcc.n	c0d00650 <__udivsi3+0xd8>
c0d0064c:	00cb      	lsls	r3, r1, #3
c0d0064e:	1ac0      	subs	r0, r0, r3
c0d00650:	4152      	adcs	r2, r2
c0d00652:	0883      	lsrs	r3, r0, #2
c0d00654:	428b      	cmp	r3, r1
c0d00656:	d301      	bcc.n	c0d0065c <__udivsi3+0xe4>
c0d00658:	008b      	lsls	r3, r1, #2
c0d0065a:	1ac0      	subs	r0, r0, r3
c0d0065c:	4152      	adcs	r2, r2
c0d0065e:	0843      	lsrs	r3, r0, #1
c0d00660:	428b      	cmp	r3, r1
c0d00662:	d301      	bcc.n	c0d00668 <__udivsi3+0xf0>
c0d00664:	004b      	lsls	r3, r1, #1
c0d00666:	1ac0      	subs	r0, r0, r3
c0d00668:	4152      	adcs	r2, r2
c0d0066a:	1a41      	subs	r1, r0, r1
c0d0066c:	d200      	bcs.n	c0d00670 <__udivsi3+0xf8>
c0d0066e:	4601      	mov	r1, r0
c0d00670:	4152      	adcs	r2, r2
c0d00672:	4610      	mov	r0, r2
c0d00674:	4770      	bx	lr
c0d00676:	e7ff      	b.n	c0d00678 <__udivsi3+0x100>
c0d00678:	b501      	push	{r0, lr}
c0d0067a:	2000      	movs	r0, #0
c0d0067c:	f000 f806 	bl	c0d0068c <__aeabi_idiv0>
c0d00680:	bd02      	pop	{r1, pc}
c0d00682:	46c0      	nop			; (mov r8, r8)

c0d00684 <__aeabi_uidivmod>:
c0d00684:	2900      	cmp	r1, #0
c0d00686:	d0f7      	beq.n	c0d00678 <__udivsi3+0x100>
c0d00688:	e776      	b.n	c0d00578 <__udivsi3>
c0d0068a:	4770      	bx	lr

c0d0068c <__aeabi_idiv0>:
c0d0068c:	4770      	bx	lr
c0d0068e:	46c0      	nop			; (mov r8, r8)

c0d00690 <__aeabi_memclr>:
c0d00690:	b510      	push	{r4, lr}
c0d00692:	2200      	movs	r2, #0
c0d00694:	f000 f809 	bl	c0d006aa <__aeabi_memset>
c0d00698:	bd10      	pop	{r4, pc}

c0d0069a <__aeabi_memcpy>:
c0d0069a:	b510      	push	{r4, lr}
c0d0069c:	f000 f80c 	bl	c0d006b8 <memcpy>
c0d006a0:	bd10      	pop	{r4, pc}

c0d006a2 <__aeabi_memmove>:
c0d006a2:	b510      	push	{r4, lr}
c0d006a4:	f000 f811 	bl	c0d006ca <memmove>
c0d006a8:	bd10      	pop	{r4, pc}

c0d006aa <__aeabi_memset>:
c0d006aa:	000b      	movs	r3, r1
c0d006ac:	b510      	push	{r4, lr}
c0d006ae:	0011      	movs	r1, r2
c0d006b0:	001a      	movs	r2, r3
c0d006b2:	f000 f81d 	bl	c0d006f0 <memset>
c0d006b6:	bd10      	pop	{r4, pc}

c0d006b8 <memcpy>:
c0d006b8:	2300      	movs	r3, #0
c0d006ba:	b510      	push	{r4, lr}
c0d006bc:	429a      	cmp	r2, r3
c0d006be:	d100      	bne.n	c0d006c2 <memcpy+0xa>
c0d006c0:	bd10      	pop	{r4, pc}
c0d006c2:	5ccc      	ldrb	r4, [r1, r3]
c0d006c4:	54c4      	strb	r4, [r0, r3]
c0d006c6:	3301      	adds	r3, #1
c0d006c8:	e7f8      	b.n	c0d006bc <memcpy+0x4>

c0d006ca <memmove>:
c0d006ca:	b510      	push	{r4, lr}
c0d006cc:	4288      	cmp	r0, r1
c0d006ce:	d902      	bls.n	c0d006d6 <memmove+0xc>
c0d006d0:	188b      	adds	r3, r1, r2
c0d006d2:	4298      	cmp	r0, r3
c0d006d4:	d303      	bcc.n	c0d006de <memmove+0x14>
c0d006d6:	2300      	movs	r3, #0
c0d006d8:	e007      	b.n	c0d006ea <memmove+0x20>
c0d006da:	5c8b      	ldrb	r3, [r1, r2]
c0d006dc:	5483      	strb	r3, [r0, r2]
c0d006de:	3a01      	subs	r2, #1
c0d006e0:	d2fb      	bcs.n	c0d006da <memmove+0x10>
c0d006e2:	bd10      	pop	{r4, pc}
c0d006e4:	5ccc      	ldrb	r4, [r1, r3]
c0d006e6:	54c4      	strb	r4, [r0, r3]
c0d006e8:	3301      	adds	r3, #1
c0d006ea:	429a      	cmp	r2, r3
c0d006ec:	d1fa      	bne.n	c0d006e4 <memmove+0x1a>
c0d006ee:	e7f8      	b.n	c0d006e2 <memmove+0x18>

c0d006f0 <memset>:
c0d006f0:	0003      	movs	r3, r0
c0d006f2:	1882      	adds	r2, r0, r2
c0d006f4:	4293      	cmp	r3, r2
c0d006f6:	d100      	bne.n	c0d006fa <memset+0xa>
c0d006f8:	4770      	bx	lr
c0d006fa:	7019      	strb	r1, [r3, #0]
c0d006fc:	3301      	adds	r3, #1
c0d006fe:	e7f9      	b.n	c0d006f4 <memset+0x4>

c0d00700 <setjmp>:
c0d00700:	c0f0      	stmia	r0!, {r4, r5, r6, r7}
c0d00702:	4641      	mov	r1, r8
c0d00704:	464a      	mov	r2, r9
c0d00706:	4653      	mov	r3, sl
c0d00708:	465c      	mov	r4, fp
c0d0070a:	466d      	mov	r5, sp
c0d0070c:	4676      	mov	r6, lr
c0d0070e:	c07e      	stmia	r0!, {r1, r2, r3, r4, r5, r6}
c0d00710:	3828      	subs	r0, #40	; 0x28
c0d00712:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d00714:	2000      	movs	r0, #0
c0d00716:	4770      	bx	lr

c0d00718 <longjmp>:
c0d00718:	3010      	adds	r0, #16
c0d0071a:	c87c      	ldmia	r0!, {r2, r3, r4, r5, r6}
c0d0071c:	4690      	mov	r8, r2
c0d0071e:	4699      	mov	r9, r3
c0d00720:	46a2      	mov	sl, r4
c0d00722:	46ab      	mov	fp, r5
c0d00724:	46b5      	mov	sp, r6
c0d00726:	c808      	ldmia	r0!, {r3}
c0d00728:	3828      	subs	r0, #40	; 0x28
c0d0072a:	c8f0      	ldmia	r0!, {r4, r5, r6, r7}
c0d0072c:	0008      	movs	r0, r1
c0d0072e:	d100      	bne.n	c0d00732 <longjmp+0x1a>
c0d00730:	2001      	movs	r0, #1
c0d00732:	4718      	bx	r3

c0d00734 <strlcpy>:
c0d00734:	b5f0      	push	{r4, r5, r6, r7, lr}
c0d00736:	0005      	movs	r5, r0
c0d00738:	2a00      	cmp	r2, #0
c0d0073a:	d014      	beq.n	c0d00766 <strlcpy+0x32>
c0d0073c:	1e50      	subs	r0, r2, #1
c0d0073e:	2a01      	cmp	r2, #1
c0d00740:	d01c      	beq.n	c0d0077c <strlcpy+0x48>
c0d00742:	002c      	movs	r4, r5
c0d00744:	000a      	movs	r2, r1
c0d00746:	0016      	movs	r6, r2
c0d00748:	0027      	movs	r7, r4
c0d0074a:	7836      	ldrb	r6, [r6, #0]
c0d0074c:	3201      	adds	r2, #1
c0d0074e:	3401      	adds	r4, #1
c0d00750:	0013      	movs	r3, r2
c0d00752:	0025      	movs	r5, r4
c0d00754:	703e      	strb	r6, [r7, #0]
c0d00756:	2e00      	cmp	r6, #0
c0d00758:	d00d      	beq.n	c0d00776 <strlcpy+0x42>
c0d0075a:	3801      	subs	r0, #1
c0d0075c:	2800      	cmp	r0, #0
c0d0075e:	d1f2      	bne.n	c0d00746 <strlcpy+0x12>
c0d00760:	2200      	movs	r2, #0
c0d00762:	702a      	strb	r2, [r5, #0]
c0d00764:	e000      	b.n	c0d00768 <strlcpy+0x34>
c0d00766:	000b      	movs	r3, r1
c0d00768:	001a      	movs	r2, r3
c0d0076a:	3201      	adds	r2, #1
c0d0076c:	1e50      	subs	r0, r2, #1
c0d0076e:	7800      	ldrb	r0, [r0, #0]
c0d00770:	0013      	movs	r3, r2
c0d00772:	2800      	cmp	r0, #0
c0d00774:	d1f9      	bne.n	c0d0076a <strlcpy+0x36>
c0d00776:	1a58      	subs	r0, r3, r1
c0d00778:	3801      	subs	r0, #1
c0d0077a:	bdf0      	pop	{r4, r5, r6, r7, pc}
c0d0077c:	000b      	movs	r3, r1
c0d0077e:	e7ef      	b.n	c0d00760 <strlcpy+0x2c>

c0d00780 <strnlen>:
c0d00780:	0003      	movs	r3, r0
c0d00782:	1841      	adds	r1, r0, r1
c0d00784:	428b      	cmp	r3, r1
c0d00786:	d002      	beq.n	c0d0078e <strnlen+0xe>
c0d00788:	781a      	ldrb	r2, [r3, #0]
c0d0078a:	2a00      	cmp	r2, #0
c0d0078c:	d101      	bne.n	c0d00792 <strnlen+0x12>
c0d0078e:	1a18      	subs	r0, r3, r0
c0d00790:	4770      	bx	lr
c0d00792:	3301      	adds	r3, #1
c0d00794:	e7f6      	b.n	c0d00784 <strnlen+0x4>
c0d00796:	7830      	.short	0x7830
	...

c0d00799 <HEXDIGITS>:
c0d00799:	3130 3332 3534 3736 3938 6261 6463 6665     0123456789abcdef
c0d007a9:	4500 5252 524f 3000 5200 6369 636f 6568     .ERROR.0.Ricoche
c0d007b9:	0074 7055 7264 6761 0065 6d41 756f 746e     t.Updrage.Amount
	...

c0d007ca <UPGRADE_SELECTOR>:
c0d007ca:	9745 037d 0000                              E.}...

c0d007d0 <RICOCHET_SELECTORS>:
c0d007d0:	07ca c0d0 7445 6568 6572 6d75 0000 0000     ....Ethereum....

c0d007e0 <_etext>:
	...
