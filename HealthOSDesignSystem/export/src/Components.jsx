const { useState } = React;

const Capsule = ({ state = 'pending', children }) => (
  <span className="capsule" data-state={state}>
    <span style={{width:6,height:6,borderRadius:'50%',background:'currentColor'}}/>
    {children}
  </span>
);

const Button = ({ kind = 'default', icon, children, disabled, onClick }) => {
  const cls = `btn btn-${kind}` + (disabled ? ' is-disabled' : '');
  return <button className={cls} disabled={disabled} onClick={onClick}>
    {icon && <i data-lucide={icon} style={{width:14,height:14}}/>}
    <span>{children}</span>
  </button>;
};

const GlassCard = ({ title, accessory, children, style }) => (
  <section className="glass-card" style={style}>
    {(title || accessory) && (
      <header className="glass-card__head">
        {title && <h3 className="glass-card__title">{title}</h3>}
        {accessory}
      </header>
    )}
    <div className="glass-card__body">{children}</div>
  </section>
);

const OutputBlock = ({ title, children }) => (
  <div className="output-block">
    <div className="output-block__title">{title}</div>
    <div className="output-block__body">{children}</div>
  </div>
);

const Banner = ({ kind = 'info', title, children }) => (
  <div className={`banner banner-${kind}`}>
    <span className="banner__ic">{kind === 'info' ? 'i' : kind === 'denied' || kind === 'failed' ? '×' : '!'}</span>
    <span><strong>{title}</strong> · {children}</span>
  </div>
);

const Field = ({ label, children }) => (
  <label className="field">
    <span className="field__label">{label}</span>
    {children}
  </label>
);

const Segmented = ({ value, onChange, options }) => (
  <div className="seg">
    {options.map(o => (
      <button key={o.value} aria-selected={value === o.value} onClick={() => onChange(o.value)}>
        {o.label}
      </button>
    ))}
  </div>
);

const LabeledRow = ({ k, v }) => (
  <div className="labeled-row"><span className="labeled-row__k">{k}</span><span className="labeled-row__v">{v}</span></div>
);

Object.assign(window, { Capsule, Button, GlassCard, OutputBlock, Banner, Field, Segmented, LabeledRow });
