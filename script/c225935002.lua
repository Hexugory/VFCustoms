--VF Bryce
--Logical Nonsense
--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Special summon itself, ignition effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.sscon)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	--If sent to grave by VF, destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x0226}
--Check for "VF" monster
function s.filter1(c)
	return c:IsSetCard(0x0226) and c:IsMonster()
end
--Check for target to send to graveyard
function s.tgfilter(c)
	return c:IsSetCard(0x0226) and c:IsMonster() and c:IsAbleToGrave()
end
--Check for target to send to graveyard
function s.rcfilter(c)
	return c:IsCode(gr:GetFirst():GetCode())
end
--Does something that fits "filter" exist
function s.sscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,e:GetHandler())
	--return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND,0,1,nil)
end
--Activation legality
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	gr=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND,0,1,1,e:GetHandler(),e,tp)
	local rc=Duel.GetMatchingGroup(s.rcfilter, tp, LOCATION_DECK, 0, nil)
	local gg=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,rc)
	local targets = Group.CreateGroup():AddCard(gr):AddCard(gg):AddCard(e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE,targets,3,0,0)
	Duel.SetTargetCard(targets)
end
--Performing the effect of special summoning itself
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	local targets = Duel.GetTargetCards(e)
	local gr = targets.GetFirst()
	local gg = targets.GetNext()
	local gs = targets.GetNext()
	Duel.ConfirmCards(1-tp,gr)
	Duel.SpecialSummon(gs,0,tp,tp,false,false,POS_FACEUP)
	Duel.SendtoGrave(gg,REASON_EFFECT)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_EFFECT and re:GetHandler():IsSetCard(0x0226)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
		Duel.Damage(1-tp, tc:GetAttack(), REASON_EFFECT)
	end
end