import React, { useState, useEffect } from "react";
import {
  Text,
  Flex,
  Title,
  ActionIcon,
  RingProgress,
  Image,
} from "@mantine/core";
import { motion } from "framer-motion";

interface InteractionProps {
  visible: boolean;
  deathSeconds: number;
  binderRevive: string;
}

const Interaction: React.FC<InteractionProps> = ({
  visible,
  deathSeconds: initialDeathSeconds,
  binderRevive,
}) => {
  const [deathSeconds, setDeathSeconds] = useState(initialDeathSeconds);


  useEffect(() => {
    if (visible) {
      setDeathSeconds(initialDeathSeconds);
    } else {

      setDeathSeconds(initialDeathSeconds);
    }
  }, [visible, initialDeathSeconds]);

  useEffect(() => {
    if (visible && deathSeconds > 0) {

      const interval = setInterval(() => {
        setDeathSeconds((prev) => {
          if (prev <= 1) {
            clearInterval(interval); 
            return 0;
          }
          return prev - 1;
        });
      }, 1000);

      return () => clearInterval(interval); 
    }
  }, [visible, deathSeconds]);

  const progress = (deathSeconds / initialDeathSeconds) * 100;

  return (
    <motion.div
      className={`interactionHandler ${visible ? "slide-in" : "slide-out"}`}
      style={{
        display: "flex",
        position: "fixed",
        top: 0,
        left: 0,
        width: "100%",
        height: "100%",
        zIndex: 9999,
        backgroundColor: "rgba(69, 10, 10, 0.5)",
      }}
      initial={{ opacity: 0 }}
      animate={{ opacity: visible ? 1 : 0 }}
      transition={{ duration: 0.7 }}
    >
      <Flex
        justify="center"
        align="center"
        direction="column"
        style={{
          position: "relative",
          zIndex: 2,
          height: "100%",
          color: "#fff",
          fontFamily: "'Roboto', sans-serif",
          textAlign: "center",
        }}
      >
        <Image
          maw={140}
          mx="auto"
          radius="md"
          src="https://cdn-icons-png.flaticon.com/128/2699/2699654.png"
          alt="Random image"
        />

        <Title tt="uppercase" order={2} size={40}>
          You Are Dead
        </Title>
        <Text color="gray.3" size="lg">
          {`You have ${deathSeconds} seconds until revival`}
        </Text>

        <RingProgress
          size={120}
          thickness={6}
          sections={[{ value: progress, color: "red" }]}
          label={<Text size="xl">{deathSeconds}s</Text>}
        />

        <Flex gap="xs" justify="center" align="center" direction="row" mt={600}>
          <ActionIcon
            radius="xs"
            size={55}
            style={{
              backgroundColor: "rgba(153, 27, 27, 0.8)",
              border: "1px solid rgba(255, 255, 255, 0.2)",
              pointerEvents: "none",
            }}
          >
            <Text size="xl">{binderRevive || "E"}</Text>
          </ActionIcon>
          <Flex justify="flex-start" align="flex-start" direction="column" wrap="wrap">
            <Text color="gray.3" size="md">
              Press to Call Medic
            </Text>
            <Text color="dimmed" size="sm">
              You have to pay 3000
            </Text>
          </Flex>
        </Flex>
      </Flex>
    </motion.div>
  );
};

export default Interaction;
