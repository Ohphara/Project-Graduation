@echo off
REM ****************************************************************************
REM Vivado (TM) v2022.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Sun Mar 30 18:05:04 +0900 2025
REM SW Build 3526262 on Mon Apr 18 15:48:16 MDT 2022
REM
REM IP Build 3524634 on Mon Apr 18 20:55:01 MDT 2022
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim tb_PE_primitive_behav -key {Behavioral:sim_1:Functional:tb_PE_primitive} -tclbatch tb_PE_primitive.tcl -view C:/LAB/Project_Graduation/Project-Graduation/work_BH/eyeriss_core/tb_PE_core_new_behav.wcfg -log simulate.log"
call xsim  tb_PE_primitive_behav -key {Behavioral:sim_1:Functional:tb_PE_primitive} -tclbatch tb_PE_primitive.tcl -view C:/LAB/Project_Graduation/Project-Graduation/work_BH/eyeriss_core/tb_PE_core_new_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
