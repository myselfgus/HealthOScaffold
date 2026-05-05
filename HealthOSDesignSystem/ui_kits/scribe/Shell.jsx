const { useState: useStateScribe } = React;

const TrafficLights = () => (
  <div className="tl">
    <span className="tl-dot tl-r"/><span className="tl-dot tl-y"/><span className="tl-dot tl-g"/>
  </div>
);

const Sidebar = ({ activeSession, onPick }) => {
  const items = [
    { id: 'today', label: 'Today', icon: 'calendar', count: 3 },
    { id: 'pending', label: 'Pending gates', icon: 'clock', count: 2 },
    { id: 'history', label: 'Session history', icon: 'history' },
    { id: 'audit', label: 'Audit slice', icon: 'git-branch' },
  ];
  const sessions = [
    { id: 's1', tok: 'PT-BR-9C1F-A4E2', state: 'active', when: '14:02' },
    { id: 's2', tok: 'PT-BR-3D8E-B7C1', state: 'pending', when: '13:14' },
    { id: 's3', tok: 'PT-BR-7A2B-E0F4', state: 'final', when: '11:48' },
    { id: 's4', tok: 'PT-BR-5E9C-D2A8', state: 'withheld', when: 'Yesterday' },
  ];
  return <aside className="sb">
    <div className="sb-section">
      <div className="sb-h">Workspace</div>
      {items.map(i => (
        <div key={i.id} className="sb-item">
          <i data-lucide={i.icon}/>
          <span>{i.label}</span>
          {i.count != null && <span className="sb-count">{i.count}</span>}
        </div>
      ))}
    </div>
    <div className="sb-section">
      <div className="sb-h">Sessions · today</div>
      {sessions.map(s => (
        <div key={s.id}
             className={`sb-item sb-session ${activeSession === s.id ? 'is-active' : ''}`}
             onClick={() => onPick(s.id)}>
          <Capsule state={s.state}>{s.state}</Capsule>
          <span className="sb-tok">{s.tok}</span>
          <span className="sb-when">{s.when}</span>
        </div>
      ))}
    </div>
    <div className="sb-section sb-foot">
      <div className="sb-item"><i data-lucide="settings"/><span>Settings</span></div>
    </div>
  </aside>;
};

const Toolbar = ({ stateLabel, runtimeLabel }) => (
  <div className="tb">
    <TrafficLights/>
    <div className="tb-title">
      <img src="../../assets/healthos-mark.svg" alt="" width="20" height="20"/>
      <span>HealthOS · Scribe</span>
    </div>
    <div className="tb-search"><i data-lucide="search"/><span>Search patient or session</span></div>
    <div className="tb-right">
      <Capsule state="info">{runtimeLabel}</Capsule>
      <Capsule state={stateLabel === 'active' ? 'active' : stateLabel === 'degraded' ? 'degraded' : 'pending'}>{stateLabel}</Capsule>
      <i data-lucide="bell"/>
    </div>
  </div>
);

Object.assign(window, { Sidebar, Toolbar, TrafficLights });
