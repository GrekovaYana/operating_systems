# Автор: Грекова Я.В., группа 02271-ДБ

CC = gcc
CFLAGS = -Wall -Wextra -Iinclude -O2 -pthread
LDFLAGS = -lrt -lpthread

SRC_DIR = src
OBJ_DIR = obj
TARGET = parallel_fact_program

SRCS = $(wildcard $(SRC_DIR)/*.c)
OBJS = $(patsubst $(SRC_DIR)/%.c,$(OBJ_DIR)/%.o,$(SRCS))

all: $(OBJ_DIR) $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ $(LDFLAGS)

$(OBJ_DIR)/%.o: $(SRC_DIR)/%.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OBJ_DIR):
	mkdir -p $@

clean:
	rm -rf $(OBJ_DIR) $(TARGET)

.PHONY: all clean