#!/bin/bash
# Comprehensive demo showing both formats and scrollable graph

cd "$(dirname "$0")/../build"

echo "═══════════════════════════════════════════════════════"
echo "  FPGA Sequencer GUI - Comprehensive Demo"
echo "═══════════════════════════════════════════════════════"
echo ""
echo "This demo will:"
echo "  1. Send text format commands"
echo "  2. Send binary format commands"
echo "  3. Demonstrate graph scrolling with many samples"
echo ""
echo "Watch the GUI window to see:"
echo "  ✓ Beat buttons changing colors (green=active, gray=off)"
echo "  ✓ Pitch values displayed on buttons"
echo "  ✓ Pitch graph growing and auto-scrolling"
echo "  ✓ Horizontal scrollbar appearing"
echo ""
read -p "Press Enter to start demo..."
echo ""

{
    echo "Phase 1: Text Format Commands"
    sleep 1
    echo "BEAT 0 3"
    sleep 0.4
    echo "BEAT 1 5"
    sleep 0.4
    echo "BEAT 2 7"
    sleep 0.4
    
    echo ""
    echo "Phase 2: Binary Format Commands"
    sleep 1
    echo "0011010"  # beat 3, pitch 2
    sleep 0.4
    echo "0100100"  # beat 4, pitch 4
    sleep 0.4
    echo "0101110"  # beat 5, pitch 6
    sleep 0.4
    
    echo ""
    echo "Phase 3: Rapid Updates (test scrolling)"
    sleep 1
    
    # Send many updates to test graph scrolling
    for i in {0..15}; do
        beat=$(printf "%04d" $(echo "obase=2; $i" | bc))
        pitch=$(printf "%03d" $(echo "obase=2; ($i % 7 + 1)" | bc))
        echo "${beat}${pitch}"
        sleep 0.2
    done
    
    echo ""
    echo "Phase 4: Turn off some beats"
    sleep 1
    echo "0001000"  # beat 1, pitch 0 (off)
    sleep 0.4
    echo "0100000"  # beat 4, pitch 0 (off)
    sleep 0.4
    
    echo ""
    echo "Demo complete! Check the GUI:"
    echo "  • Some beats are green (active) with pitch values"
    echo "  • Some beats are gray (inactive)"
    echo "  • Pitch graph shows history - use scrollbar!"
    sleep 3
    
} | ./src/fpga_sequencer_gui

echo ""
echo "═══════════════════════════════════════════════════════"
echo "Demo finished!"
echo ""
echo "Try the two-terminal workflow:"
echo "  Terminal 1: ./scripts/run_gui.sh"
echo "  Terminal 2: ./scripts/send_commands.sh"
echo "═══════════════════════════════════════════════════════"
