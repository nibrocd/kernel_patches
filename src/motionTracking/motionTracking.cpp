#include <unistd.h>
#include <chrono>
#include <unistd.h>
#include <stdint.h>
#include <sys/mman.h>
#include <fcntl.h>

#include <opencv2/opencv.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/highgui.hpp>

#define LED_ADDR 0x41210000

int main(int argc, char* argv[])
{

	int devmem = open("/dev/mem", O_RDWR|O_SYNC);
	int pgsz = getpagesize();
	uint32_t* mem = (uint32_t*)mmap(NULL, pgsz, PROT_READ|PROT_WRITE|PROT_EXEC, MAP_SHARED, devmem, LED_ADDR);
	*mem = 0x0;

	cv::VideoCapture cap;
	cap.set(cv::CAP_PROP_CONVERT_RGB, false);
	cap.set(cv::CAP_MODE_YUYV, 1);
	cap.open("v4l2src device=/dev/video0 ! video/x-raw,format=(string)UYVY,width=640,height=480,framerate=(fraction)30/1 ! appsink", cv::CAP_GSTREAMER);
	if(!cap.isOpened()) {
		std::cout << "Failed to open camera." << std::endl;
		return (-1);
	}
	std::cout << "opened camera" << std::endl;

	unsigned int width  = cap.get(CV_CAP_PROP_FRAME_WIDTH); 
	unsigned int height = cap.get(CV_CAP_PROP_FRAME_HEIGHT); 
	unsigned int fps    = cap.get(CV_CAP_PROP_FPS);
	unsigned int pixels = width*height;
	std::cout <<" Frame size : "<<width<<" x "<<height<<", "<<pixels<<" Pixels "<<fps<<" FPS"<<std::endl;
    
	cv::Mat frame_in;
	cv::Mat grey(480, 640, CV_8UC1);
	cv::Mat diff(480, 640, CV_8UC1);
	int cnt = 0;

	int diffThresh  = atoi(argv[1]);
	int leftSum;
	int midSum;
	int rightSum;
	int leftPrev = 0;
	int midPrev = 0;
	int rightPrev = 0;
	int prevPos = 0;
	int absLeft = 0;
	int absMid = 0;
	int absRight = 0;
	auto prevTime = std::chrono::high_resolution_clock::now();
	auto curTime = std::chrono::high_resolution_clock::now();
	std::chrono::duration<double> frmTime;

	while(1)
	{
		if(cnt%100 == 0 && cnt > 0)
		{
			curTime = std::chrono::high_resolution_clock::now();
			frmTime = curTime - prevTime;
			std::cout << "100 frame time " << frmTime.count() << std::endl;
			prevTime = curTime;
		}

		if (!cap.read(frame_in))
		{
			std::cout<<"Capture read error"<<std::endl;
			break;
		}
		else
		{
			cv::cvtColor(frame_in, grey, CV_YUV2GRAY_Y422, 1);
			if(cnt > 0)
			{
				leftSum = 0;
				rightSum = 0;
				midSum = 0;

				#pragma omp parallel for
				for (int i = 0; i < 214; i++)
				{
					for (int j = 0; j < grey.rows; j++)
					{
						if(grey.at<uchar>(j,i) != 0)
						{
							leftSum ++;
						}
					}
				}

				#pragma omp parallel for
				for (int i = 214; i < 427; i++)
				{
					for (int j = 0; j < grey.rows; j++)
					{
						if(grey.at<uchar>(j,i) != 0)
						{
							midSum ++;
						}
					}
				}

				#pragma omp parallel for
				for (int i = 428; i < 640; i++)
				{
					for (int j = 0; j < grey.rows; j++)
					{
						if(grey.at<uchar>(j,i) != 0)
						{
							rightSum ++;
						}
					}
				}

				absLeft = abs(leftSum - leftPrev);
				absMid = abs(midSum - midPrev);
				absRight = abs(rightSum - rightPrev);
				//std::cout << "left: " << leftSum << " mid: " << midSum << " right: " << rightSum << std::endl;
				

				if(absMid > diffThresh && absMid >= absLeft && absMid >= absRight)
				{
					if(prevPos == 0)
					{
						//std::cout << "motion in mid" << std::endl;
						*mem = 0x2;
					}
					prevPos = 0;
				}
				else if(absLeft > diffThresh && absLeft >= absMid && absLeft >= absRight)
				{
					if(prevPos == 1)
					{
						//std::cout << "motion in left" << std::endl;
						*mem = 0x1;
					}
					prevPos = 1;
				}
				else if(absRight > diffThresh  && absRight >= absLeft && absRight >= absMid)
				{
					if(prevPos == -1)
					{
						//std::cout << "motion in right" << std::endl;
						*mem = 0x4;
					}
					prevPos = -1;
				}

				leftPrev = leftSum;
				rightPrev = rightSum;
				midPrev = midSum;

			}			
			cnt++;
		}

	}

	*mem = 0x0;
	cap.release();
	close(devmem);
	munmap(mem, pgsz);
	return 0;
}