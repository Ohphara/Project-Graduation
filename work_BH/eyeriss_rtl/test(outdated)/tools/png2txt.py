import cv2
import numpy as np
import random

def convert_to_fix_point(arr1, bit):
    arr2 = arr1.copy().astype(np.float32)
    arr2[arr2 < 0] = 0.0
    arr2 = np.round(np.abs(arr2) * (2 ** bit))
    arr3 = arr1.copy().astype(np.float32)
    arr3[arr3 > 0] = 0.0
    arr3 = -np.round(np.abs(-arr3) * (2 ** bit))
    arr4 = arr2 + arr3
    return arr4.astype(np.int64)

def prepare_image_from_camera(im_path):
    Verilog_flag = 0
    img = cv2.imread(im_path)
    print('Read image: {} Shape: {}'.format(im_path, img.shape))
    # 이미지 크기를 640x640으로 리사이즈
    img = cv2.resize(img, (640, 640), interpolation=cv2.INTER_CUBIC)
    print('Reduced shape: {}'.format(img.shape))

    # 그레이스케일 변환 (BGR 순서이며, 가중치는 3, 8, 5 사용)
    gray = np.zeros(img.shape[:2], dtype=np.uint16)
    gray[...] = 3 * img[:, :, 0].astype(np.uint16) + 8 * img[:, :, 1].astype(np.uint16) + 5 * img[:, :, 2].astype(np.uint16)
    gray //= 16
    print(gray[:3])

    output_image = gray
    # 최소, 최대 픽셀 값 확인
    min_pixel = output_image.min()
    max_pixel = output_image.max()
    print('Min pixel: {}'.format(min_pixel))
    print('Max pixel: {}'.format(max_pixel))

    if Verilog_flag:
        if min_pixel != 0 or max_pixel != 255:
            if max_pixel == min_pixel:
                output_image[:, :] = 0
            else:
                output_image = 255 * (output_image.astype(np.float32) - min_pixel) / (max_pixel - min_pixel)
                output_image = output_image.astype(np.uint8)

    if Verilog_flag:
        u = np.unique(output_image, return_counts=True)
        print(u)

    return output_image

def main():
    for num2test in range(1):
        img_path = 'input.png'
        verilog_path = 'output.txt'
        image = prepare_image_from_camera(img_path)
        prob = 0.01
        thres = 1 - prob
        noise = 0
        # pixel_mf 배열 크기를 640x640으로 수정
        pixel_mf = np.zeros((640, 640))
        
        if noise:
            for i in range(image.shape[0]):
                for j in range(image.shape[1]):
                    rdn = random.random()
                    if rdn < prob:
                        image[i][j] = 0
                    elif rdn > thres:
                        image[i][j] = 255

        image_one = image / 256.
        image_binary = convert_to_fix_point(image_one, 15)
        
        with open(verilog_path, 'w') as file:
            for i in range(image_binary.shape[0]):
                for j in range(image_binary.shape[1]):
                    pixel = image[i][j]
                    # 경계 부분은 평균 필터 적용 없이 넘어감
                    if i == 0 or j == 0 or i == image_binary.shape[0] - 1 or j == image_binary.shape[1] - 1:
                        pass
                    else:
                        pixel_mf[i][j] = int(image[(i-1):(i+2), (j-1):(j+2)].sum() / 9.0)
                    file.write('{:016b}\n'.format(pixel))
        
        cv2.imwrite(".\\output.png", pixel_mf)
        print(pixel_mf)

if __name__ == '__main__':
    main()