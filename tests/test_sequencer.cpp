#include "../src/sequencer_model.h"
#include "../src/uart_parser.h"
#include <gtest/gtest.h>

TEST(SequencerModelTest, ToneStorage) {
    SequencerModel m(16);
    
    m.setToneForBeat(0, 3);
    EXPECT_EQ(m.getToneForBeat(0), 3);

    m.setToneForBeat(5, 7);
    EXPECT_EQ(m.getToneForBeat(5), 7);
    
    // Out of bounds should be safe
    m.setToneForBeat(99, 5);
    EXPECT_EQ(m.getToneForBeat(99), 0);
}

TEST(SequencerModelTest, CurrentBeat) {
    SequencerModel m(16);
    
    EXPECT_EQ(m.currentBeat(), 0);
    
    m.setCurrentBeat(5);
    EXPECT_EQ(m.currentBeat(), 5);
    
    m.setCurrentBeat(15);
    EXPECT_EQ(m.currentBeat(), 15);
}

TEST(UARTParserTest, ParseToneCommand) {
    SequencerModel m(16);
    UARTParser parser(&m);

    parser.parseLine("TONE 2 5");
    EXPECT_EQ(m.getToneForBeat(2), 5);

    parser.parseLine("TONE 0 7");
    EXPECT_EQ(m.getToneForBeat(0), 7);
}

TEST(UARTParserTest, ParseBeatCommand) {
    SequencerModel m(16);
    UARTParser parser(&m);

    parser.parseLine("BEAT 3");
    EXPECT_EQ(m.currentBeat(), 3);

    parser.parseLine("BEAT 12");
    EXPECT_EQ(m.currentBeat(), 12);
}

TEST(UARTParserTest, ParseMultipleCommands) {
    SequencerModel m(16);
    UARTParser parser(&m);
    
    parser.parseLine("TONE 0 1");
    parser.parseLine("TONE 1 2");
    parser.parseLine("TONE 2 3");
    parser.parseLine("BEAT 1");
    
    EXPECT_EQ(m.getToneForBeat(0), 1);
    EXPECT_EQ(m.getToneForBeat(1), 2);
    EXPECT_EQ(m.getToneForBeat(2), 3);
    EXPECT_EQ(m.currentBeat(), 1);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    return RUN_ALL_TESTS();
}
