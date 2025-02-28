import numpy as np
import cv2

def main():
    print("시작", flush=True)
    try:
        with open("output.txt", 'rb') as f:
            lines = f.readlines()
    except Exception as e:
        print("output.txt 파일을 열지 못했습니다:", e)
        return

    # 잘못된 값("xxxxxxxxxxxxxxxx")을 0으로 대체 후 정수 변환
    processed_lines = [
        b'0000000000000000\r\n' if line == b'xxxxxxxxxxxxxxxx\r\n' else line
        for line in lines
    ]
    
    try:
        pixels = [int(line.strip(), base=2) for line in processed_lines]
    except Exception as e:
        print("픽셀 데이터를 정수로 변환하는 중 오류 발생:", e)
        return

    pixels = np.asarray(pixels)
    expected_pixels = 640 * 640  # 409600

    if pixels.size != expected_pixels:
        print("픽셀 수가 예상과 다릅니다: {} (예상: {})".format(pixels.size, expected_pixels))
        return

    # 1차원 배열을 640x640 행렬로 재구성
    image_array = np.reshape(pixels, (640, 640))
    
    # 이미지 저장
    result = cv2.imwrite("lena_out.png", image_array)
    if result:
        print("이미지가 성공적으로 저장되었습니다: lena_out.png")
    else:
        print("이미지 저장에 실패했습니다.")
    
    # txt 파일로도 저장 (디버깅용)
    np.savetxt("png_out.txt", image_array, fmt="%4d")

if __name__ == "__main__":
    main()