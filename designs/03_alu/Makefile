DESIGN     = alu
SRC_DIR    = src
TB_DIR     = tb
BUILD_DIR  = build

.PHONY: sim clean

sim: $(BUILD_DIR)/V$(DESIGN)
	./$(BUILD_DIR)/V$(DESIGN)

$(BUILD_DIR)/V$(DESIGN): $(SRC_DIR)/$(DESIGN).v $(TB_DIR)/tb_$(DESIGN).cpp
	mkdir -p $(BUILD_DIR)
	verilator --cc --exe --build -Wno-fatal \
		-Mdir $(BUILD_DIR) \
		--top-module $(DESIGN) \
		$(SRC_DIR)/$(DESIGN).v \
		$(TB_DIR)/tb_$(DESIGN).cpp

clean:
	rm -rf $(BUILD_DIR)
