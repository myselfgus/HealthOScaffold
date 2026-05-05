const { useState: useS, useEffect: useE } = React;

// --- step 1: empty / opening ---
const SessionStartCard = ({ onStart, opening }) => (
  <GlassCard title="1 · Session start"
             accessory={<Capsule state={opening ? 'pending' : 'info'}>{opening ? 'opening' : 'idle'}</Capsule>}>
    <p className="muted">Abra a sessão para habilitar seleção de paciente e captura por texto seeded ou áudio local.</p>
    <Button kind="primary" icon="play" disabled={opening} onClick={onStart}>
      {opening ? 'Opening session…' : 'Open professional session'}
    </Button>
  </GlassCard>
);

// --- step 2: workspace ---
const WorkspaceCard = ({ patient, onPickPatient, captureMode, setCaptureMode, captureText, setCaptureText, onSubmit, canSubmit, onAdvance, canAdvance }) => (
  <GlassCard title="2 · Patient · capture · advance"
             accessory={<Capsule state="active">session open</Capsule>}>
    <Field label="Patient token">
      <select value={patient || ''} onChange={e => onPickPatient(e.target.value || null)}>
        <option value="">Select a patient</option>
        <option value="PT-BR-9C1F-A4E2">PT-BR-9C1F-A4E2 · M, 38</option>
        <option value="PT-BR-3D8E-B7C1">PT-BR-3D8E-B7C1 · F, 52</option>
        <option value="PT-BR-7A2B-E0F4">PT-BR-7A2B-E0F4 · M, 24</option>
      </select>
    </Field>

    <Field label="Capture mode">
      <Segmented value={captureMode} onChange={setCaptureMode} options={[
        { value: 'seeded_text', label: 'Seeded text' },
        { value: 'local_audio_file', label: 'Local audio file' },
      ]}/>
    </Field>

    {captureMode === 'seeded_text' ? (
      <Field label="Capture text (seeded)">
        <textarea value={captureText} onChange={e => setCaptureText(e.target.value)} rows={4}/>
      </Field>
    ) : (
      <Field label="Local audio file">
        <div className="audio-row">
          <i data-lucide="file-audio"/>
          <span className="muted">No audio file selected.</span>
          <Button icon="folder-open">Choose audio file</Button>
        </div>
      </Field>
    )}

    <div className="row-actions">
      <Button kind="primary" icon="upload" disabled={!canSubmit} onClick={onSubmit}>Submit capture</Button>
      <Button icon="arrow-right" disabled={!canAdvance} onClick={onAdvance}>Advance to draft preview</Button>
    </div>
  </GlassCard>
);

// --- step 3: outputs ---
const OutputsCard = ({ stage, capture, transcription, retrieval, draft, gate, finalDoc }) => (
  <GlassCard title="3 · Slice outputs"
             accessory={<Capsule state={stage === 'final' ? 'final' : stage === 'gate' ? 'pending' : stage === 'draft' ? 'pending' : 'pending'}>{stage}</Capsule>}>
    <OutputBlock title="Transcript preview">
      {capture || <span className="muted">Nenhuma captura submetida ainda.</span>}
    </OutputBlock>
    <OutputBlock title="Transcription status">
      <span className="kv">status: {transcription.status} · source: {transcription.source} · audio: none</span>
    </OutputBlock>
    <OutputBlock title="Retrieval summary">
      {retrieval ? (
        <>
          <span className="kv">status: {retrieval.status} · matches: {retrieval.matches}</span>
          <ul className="hl-list">{retrieval.highlights.map((h, i) => <li key={i}>{h}</li>)}</ul>
        </>
      ) : <span className="muted">Nenhum retrieval executado ainda.</span>}
    </OutputBlock>
    <OutputBlock title="SOAP draft preview">
      {draft || <span className="muted">Nenhum draft SOAP visível ainda.</span>}
    </OutputBlock>
    <div className="kv-grid">
      <LabeledRow k="SOAP draft state" v={draft ? (gate?.resolved ? 'approved' : 'awaiting_gate') : 'empty'}/>
      <LabeledRow k="Referral draft state" v={draft ? 'draft_only' : 'none'}/>
      <LabeledRow k="Prescription draft state" v={draft ? 'draft_only' : 'none'}/>
      <LabeledRow k="GOS runtime" v={draft ? 'active' : 'inactive'}/>
      <LabeledRow k="Gate state" v={!gate ? 'none' : gate.resolved ? gate.decision : 'pending'}/>
      <LabeledRow k="Final document" v={finalDoc ? finalDoc.state : 'none'}/>
    </div>
  </GlassCard>
);

const GatePanel = ({ visible, resolved, decision, onResolve }) => {
  if (!visible) return null;
  return (
    <GlassCard title="Gate review"
               accessory={<Capsule state={resolved ? (decision === 'approved' ? 'final' : 'withheld') : 'pending'}>{resolved ? decision : 'pending'}</Capsule>}>
      <div className="meta-grid">
        <div><span className="k">Review type</span><span className="v">soap_finalization</span></div>
        <div><span className="k">Target</span><span className="v">final_document</span></div>
        <div><span className="k">Reviewer role</span><span className="v">professional</span></div>
        <div><span className="k">Rationale</span><span className="v">routine_review</span></div>
      </div>
      {!resolved ? (
        <div className="row-actions">
          <Button kind="ok" icon="check" onClick={() => onResolve('approved')}>Approve gate</Button>
          <Button kind="no" icon="x" onClick={() => onResolve('rejected')}>Reject gate</Button>
        </div>
      ) : (
        <Banner kind={decision === 'approved' ? 'info' : 'denied'} title={decision === 'approved' ? 'Gate approved' : 'Gate rejected'}>
          {decision === 'approved' ? 'Final SOAP document effectuated; provenance recorded.' : 'Artifact withheld; no document effectuated.'}
        </Banner>
      )}
    </GlassCard>
  );
};

const IssuesCard = ({ issues }) => (
  <GlassCard title="4 · Issues / degraded / deny">
    {issues.length === 0
      ? <p className="muted">Nenhum issue ativo no momento.</p>
      : <ul className="issue-list">{issues.map((i, k) => <li key={k}><Capsule state={i.kind}>{i.code}</Capsule> {i.msg}</li>)}</ul>}
  </GlassCard>
);

Object.assign(window, { SessionStartCard, WorkspaceCard, OutputsCard, GatePanel, IssuesCard });
