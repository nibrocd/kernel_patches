CC=gcc
CFLAGS=-Wall
LDLIBS+=-lopencv_core
LDLIBS+=-lopencv_imgproc
LDLIBS+=-lopencv_videoio

CFLAGS += -I/home/user/buildroot/output/host/arm-buildroot-linux-gnueabihf/sysroot/usr/lib/glib-2.0/include
CFLAGS += -I/home/user/buildroot/output/host/arm-buildroot-linux-gnueabihf/sysroot/usr/include/glib-2.0
CFLAGS += -I/home/user/buildroot/output/host/arm-buildroot-linux-gnueabihf/sysroot/usr/include/gstreamer-1.0/gst/app
CFLAGS += -I/home/user/buildroot/output/host/arm-buildroot-linux-gnueabihf/sysroot/usr/include/glib-2.0/glib
CFLAGS += -I/home/user/buildroot/output/host/arm-buildroot-linux-gnueabihf/sysroot/usr/include/gstreamer-1.0
CFLAGS += -I/home/user/buildroot/output/host/arm-buildroot-linux-gnueabihf/sysroot/usr/include/gstreamer-1.0/gst/app

motionTracking: motionTracking.cpp
	$(CC) -o '$@' '$<' $(LDLIBS) $(CFLAGS) -pthread -fopenmp

clean:
	rm -f motionTracking

