#include "../src/sequencer_model.h"
#include "../src/uart_parser.h"
#include <gtest/gtest.h>

TEST(SequencerModelTest, PitchStorage) {
    SequencerModel m(16);
    
    m.setBeatPitch(0, 3);
    EXPECT_EQ(m.getBeatPitch(0), 3);

    m.setBeatPitch(5, 7);
    EXPECT_EQ(m.getBeatPitch(5), 7);
    
    // Out of bounds should be safe
    m.setBeatPitch(99, 5);
    EXPECT_EQ(m.getBeatPitch(99), 0);
    
    // Out of range pitch (> 7) should be rejected
    m.setBeatPitch(0, 10);
    EXPECT_EQ(m.getBeatPitch(0), 3); // Should still be 3
}

TEST(SequencerModelTest, BeatActive) {
    SequencerModel m(16);
    
    EXPECT_FALSE(m.isBeatActive(0)); // pitch 0 = off
    
    m.setBeatPitch(0, 5);
    EXPECT_TRUE(m.isBeatActive(0)); // pitch > 0 = active
    
    m.setBeatPitch(0, 0);
    EXPECT_FALSE(m.isBeatActive(0)); // back to off
}

TEST(SequencerModelTest, CurrentBeat) {
    SequencerModel m(16);
    
    EXPECT_EQ(m.currentBeat(), 0);
    
    m.setCurrentBeat(5);
    EXPECT_EQ(m.currentBeat(), 5);
    
    m.setCurrentBeat(15);
    EXPECT_EQ(m.currentBeat(), 15);
}

TEST(UARTParserTest, ParseBeatWithPitch) {
    SequencerModel m(16);
    UARTParser parser(&m);

    parser.parseLine("BEAT 2 5");
    EXPECT_EQ(m.getBeatPitch(2), 5);
    EXPECT_EQ(m.currentBeat(), 2);

    parser.parseLine("BEAT 0 7");
    EXPECT_EQ(m.getBeatPitch(0), 7);
    EXPECT_EQ(m.currentBeat(), 0);
}

TEST(UARTParserTest, ParseMultipleBeats) {
    SequencerModel m(16);
    UARTParser parser(&m);
    
    parser.parseLine("BEAT 0 1");
    parser.parseLine("BEAT 1 2");
    parser.parseLine("BEAT 2 3");
    parser.parseLine("BEAT 5 0"); // Pitch 0 = off
    
    EXPECT_EQ(m.getBeatPitch(0), 1);
    EXPECT_EQ(m.getBeatPitch(1), 2);
    EXPECT_EQ(m.getBeatPitch(2), 3);
    EXPECT_EQ(m.getBeatPitch(5), 0);
    EXPECT_EQ(m.currentBeat(), 5);
    
    EXPECT_TRUE(m.isBeatActive(0));
    EXPECT_FALSE(m.isBeatActive(5));
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
