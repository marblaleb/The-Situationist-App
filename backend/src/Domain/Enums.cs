namespace Domain;

public enum Provider { Google, Apple }

public enum ActionType { Performativa, Social, Sensorial, Poetica }

public enum InterventionLevel { Bajo, Medio, Alto }

public enum EventVisibility { Public, ByProximity, HiddenUntilDiscovery }

public enum EventStatus { Active, Full, Expired, Cancelled }

public enum ParticipationRole { Participante, Observador }

public enum DerivaType { Caotica, Poetica, Social, Sensorial }

public enum DerivaStatus { Active, Completed, Abandoned }

public enum ClueType { Textual, Sensorial, Contextual }

public enum MissionStatus { Draft, Active, Archived }

public enum MissionProgressStatus { InProgress, Completed, Abandoned }

public enum ActivityLogType { EventParticipation, DerivaCompleted, MissionCompleted }
