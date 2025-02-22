#include <stdio.h>
#include "xaxidma.h"
#include "xparameters.h"

#define DMA_DEV_ID  XPAR_AXIDMA_0_DEVICE_ID
#define BRAM_ADDR   XPAR_BRAM_0_BASEADDR

XAxiDma AxiDma;

int main() {
    XAxiDma_Config *CfgPtr;
    int Status;
    u32 *BramPtr = (u32 *) BRAM_ADDR;

    // 1️⃣ UART로 메시지 출력
    printf("Initializing DMA...\n");

    // 2️⃣ DMA 초기화
    CfgPtr = XAxiDma_LookupConfig(DMA_DEV_ID);
    if (!CfgPtr) {
        printf("DMA Configuration Lookup Failed\n");
        return XST_FAILURE;
    }

    Status = XAxiDma_CfgInitialize(&AxiDma, CfgPtr);
    if (Status != XST_SUCCESS) {
        printf("DMA Initialization Failed\n");
        return XST_FAILURE;
    }

    printf("DMA Initialized Successfully!\n");

    // 3️⃣ BRAM 데이터 초기화
    printf("Writing data to BRAM...\n");
    for (int i = 0; i < 16; i++) {
        BramPtr[i] = i + 100;  // 샘플 데이터 저장
        printf("BRAM[%d] = %d\n", i, BramPtr[i]);  // 데이터 확인
    }

    // 4️⃣ DMA 전송 실행
    printf("Starting DMA Transfer...\n");
    Status = XAxiDma_SimpleTransfer(&AxiDma, (UINTPTR)BramPtr, 64, XAXIDMA_DMA_TO_DEVICE);
    if (Status != XST_SUCCESS) {
        printf("DMA Transfer Failed\n");
        return XST_FAILURE;
    }

    printf("DMA Transfer Completed Successfully!\n");

    return XST_SUCCESS;
}
